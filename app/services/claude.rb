require "net/http"
require "json"

# Claude（Anthropic）にプロンプトを送って、返ってきた文章を返すクラス
class Claude
  URL = "https://api.anthropic.com/v1/messages"
  MODEL = "claude-haiku-4-5-20251001"   # 軽くて安いモデル。ES下書きには十分

  # prompt（お願いする文章）を渡すと、AIの返事（文字列）が返ってくる
  def self.generate(prompt)
    uri = URI(URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["content-type"] = "application/json"
    request["x-api-key"] = ENV["ANTHROPIC_API_KEY"]        # .envのキーを使う
    request["anthropic-version"] = "2023-06-01"            # APIのバージョン指定（固定）
    request.body = {
      model: MODEL,
      max_tokens: 1024,                                     # 返事の最大長
      messages: [ { role: "user", content: prompt } ]      # ここにプロンプトを入れる
    }.to_json

    # 送信して、返ってきたJSONから「AIの返事の文章」だけ取り出す
    response = http.request(request)
    JSON.parse(response.body).dig("content", 0, "text")
  end
end