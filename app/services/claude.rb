require "net/http"
require "json"

# Claude（Anthropic）にプロンプトを送って、返ってきた文章を返すクラス
class Claude
  URL = "https://api.anthropic.com/v1/messages"
  MODEL = "claude-haiku-4-5-20251001"   # 軽くて安いモデル

  # 文章だけを返す（Web検索なし）
  def self.generate(prompt)
    body = {
      model: MODEL,
      max_tokens: 1024,
      messages: [ { role: "user", content: prompt } ]
    }
    data = post(body)
    data.dig("content", 0, "text")
  end

  # Web検索をしてから答えさせる
  # { text: 本番の文章, sources: 出典, searched_urls: 検索で実際に見たページのURL } を返す
  def self.generate_with_search(prompt, max_searches: 3)
    body = {
      model: MODEL,
      max_tokens: 2048,
      messages: [ { role: "user", content: prompt } ],
      tools: [ { type: "web_search_20250305", name: "web_search", max_uses: max_searches } ]
    }
    data = post(body)
    extract_text_and_sources(data)
  end

  # 返ってきたデータから、本番の文章・出典・検索で見たページのURLを取り出す
  def self.extract_text_and_sources(data)
    blocks = data["content"]
    return { text: "AIの呼び出しに失敗しました。時間をおいてもう一度試してください。", sources: [], searched_urls: [] } if blocks.nil?

    # 最後の検索結果より後ろが本番の文章（前は「調べてみます」などの前置き）
    last_search = blocks.rindex { |block| block["type"] == "web_search_tool_result" }
    answer = last_search ? blocks[(last_search + 1)..] : blocks
    texts = answer.select { |block| block["type"] == "text" }

    # 文章の中で引用された出典（タイトルとURL）
    sources = texts.flat_map { |block| block["citations"] || [] }
                   .map { |c| { title: c["title"], url: c["url"] } }
                   .uniq { |s| s[:url] }

    # 検索で実際に見たページのURL（検索に失敗した時は content が配列ではないので飛ばす）
    search_results = blocks.select { |block| block["type"] == "web_search_tool_result" }
    searched_urls = search_results.flat_map { |block| block["content"].is_a?(Array) ? block["content"] : [] }
                                  .map { |result| result["url"] }
                                  .compact
                                  .uniq

    { text: texts.map { |block| block["text"] }.join, sources: sources, searched_urls: searched_urls }
  end

  # APIにデータを送って、返事（JSON）をRubyのハッシュにして返す
  def self.post(body)
    uri = URI(URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 120   # Web検索をすると時間がかかるので、長めに待つ
    request = Net::HTTP::Post.new(uri)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV["ANTHROPIC_API_KEY"]
    request["anthropic-version"] = "2023-06-01"
    request.body = body.to_json
    JSON.parse(http.request(request).body)
  end
end