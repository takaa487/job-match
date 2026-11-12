require "net/http"
require "json"

# Anthropic の API（Claude）を呼ぶ。通信や API の失敗は Claude::Error にまとめ、呼ぶ側でエラー画面にせずメッセージを出せるようにする
class Claude
  class Error < StandardError; end

  ENDPOINT = URI("https://api.anthropic.com/v1/messages")
  MODEL = "claude-haiku-4-5-20251001"
  # つながらないときは早めにあきらめ、Web 検索で返事が遅いときは長めに待つ
  OPEN_TIMEOUT = 10
  READ_TIMEOUT = 120
  # 通信の途中で起きる失敗。どれも「AI を呼べなかった」として同じに扱う
  NETWORK_ERRORS = [ Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError ].freeze

  class << self
    # { text: 文章, sources: 文章の中で引用された出典, searched_urls: 検索で実際に見たページの URL } を返す
    def generate_with_search(prompt, max_searches: 3)
      data = post(
        model: MODEL,
        max_tokens: 2048,
        messages: [ { role: "user", content: prompt } ],
        tools: [ { type: "web_search_20250305", name: "web_search", max_uses: max_searches } ]
      )
      extract_text_and_sources(data)
    end

    private

    def post(body)
      response = Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) do |http|
        http.post(ENDPOINT.path, body.to_json, headers)
      end
      raise Error, "API がエラーを返しました（#{response.code}）" unless response.code == "200"

      JSON.parse(response.body)
    rescue *NETWORK_ERRORS, JSON::ParserError => e
      raise Error, "#{e.class}: #{e.message}"
    end

    def headers
      {
        "content-type" => "application/json",
        "x-api-key" => ENV["ANTHROPIC_API_KEY"],
        "anthropic-version" => "2023-06-01"
      }
    end

    def extract_text_and_sources(data)
      blocks = data["content"] || raise(Error, "返事に中身がありません")

      # 最後の検索結果より後ろが本番の文章（前は「調べてみます」などの前置き）
      last_search = blocks.rindex { |block| block["type"] == "web_search_tool_result" }
      answer = last_search ? blocks[(last_search + 1)..] : blocks
      texts = answer.select { |block| block["type"] == "text" }

      sources = texts.flat_map { |block| block["citations"] || [] }
        .map { |citation| { title: citation["title"], url: citation["url"] } }
        .uniq { |source| source[:url] }

      # 検索に失敗したときは content が配列ではないので飛ばす
      searched_urls = blocks.select { |block| block["type"] == "web_search_tool_result" }
        .flat_map { |block| block["content"].is_a?(Array) ? block["content"] : [] }
        .filter_map { |result| result["url"] }
        .uniq

      { text: texts.map { |block| block["text"] }.join, sources: sources, searched_urls: searched_urls }
    end
  end
end
