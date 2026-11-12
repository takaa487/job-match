require "test_helper"

class ClaudeTest < ActiveSupport::TestCase
  # 本物の通信の代わりに返す、にせものの返事
  Response = Struct.new(:code, :body)

  test "Web 検索の返事から、検索のあとの文章と、出典と、実際に見たページを取り出す" do
    body = {
      content: [
        { type: "text", text: "調べてみます" },
        { type: "web_search_tool_result", content: [ { url: "https://example.com/a" }, { url: "https://example.com/b" } ] },
        { type: "text", text: "答えです", citations: [ { title: "A社", url: "https://example.com/a" } ] }
      ]
    }.to_json

    result = Net::HTTP.stub(:start, ->(*, **) { Response.new("200", body) }) do
      Claude.generate_with_search("質問")
    end

    assert_equal "答えです", result[:text]
    assert_equal [ { title: "A社", url: "https://example.com/a" } ], result[:sources]
    assert_equal [ "https://example.com/a", "https://example.com/b" ], result[:searched_urls]
  end

  test "API がエラーを返したら、返事の番号（記録を見て原因を調べるため）つきで Claude::Error にする" do
    error = Net::HTTP.stub(:start, ->(*, **) { Response.new("529", { type: "error" }.to_json) }) do
      assert_raises(Claude::Error) { Claude.generate_with_search("質問") }
    end

    assert_includes error.message, "529"
  end

  test "時間切れなど通信の失敗も、Claude::Error にする" do
    Net::HTTP.stub(:start, ->(*, **) { raise Net::ReadTimeout }) do
      assert_raises(Claude::Error) { Claude.generate_with_search("質問") }
    end
  end
end
