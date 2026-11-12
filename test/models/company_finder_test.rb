require "test_helper"

class CompanyFinderTest < ActiveSupport::TestCase
  test "AI の返事から、探した会社の一覧を作る" do
    companies = find_with(
      text: '[{"name": "テスト商事", "industry": "商社", "summary": "食品の専門商社", "salary": "26万円", "work_location": "本社：大阪", "source_url": "https://example.com/test"}]',
      searched_urls: [ "https://example.com/test" ]
    )

    assert_equal [ "テスト商事" ], companies.map { |company| company[:name] }
    assert_equal "26万円", companies.first[:salary]
    assert_equal "https://example.com/test", companies.first[:source_url]
  end

  test "検索で実際に見ていない URL は、出典にしない" do
    companies = find_with(
      text: '[{"name": "テスト商事", "source_url": "https://example.com/made-up"}]',
      searched_urls: [ "https://example.com/test" ]
    )

    assert_nil companies.first[:source_url]
  end

  test "初任給や勤務地が分からなければ「不明」にする" do
    companies = find_with(text: '[{"name": "テスト商事", "salary": "", "work_location": " "}]')

    assert_equal "不明", companies.first[:salary]
    assert_equal "不明", companies.first[:work_location]
  end

  test "もう登録されている会社は、「株式会社」やスペースの違いがあっても外す" do
    companies = find_with(text: '[{"name": "株式会社　サンプル銀行"}, {"name": "テスト商事"}]')

    assert_equal [ "テスト商事" ], companies.map { |company| company[:name] }
  end

  test "返事が JSON として読めなければ、空の一覧にする" do
    assert_empty find_with(text: "うまく探せませんでした")
    assert_empty find_with(text: "[ここはJSONではありません]")
  end

  test "6社以上返ってきても、5社までにする" do
    list = (1..6).map { |number| { name: "テスト商事#{number}" } }

    assert_equal 5, find_with(text: list.to_json).size
  end

  test "AI への条件に、業界・初任給・地方の都道府県・登録済みの会社を入れる" do
    prompt = nil
    fake_search = ->(text, **) { prompt = text; { text: "[]", sources: [], searched_urls: [] } }

    Claude.stub(:generate_with_search, fake_search) do
      CompanyFinder.new(industries: [ "金融" ], areas: [ "関東" ], min_salary: 250_000).call
    end

    assert_includes prompt, "業界：金融"
    assert_includes prompt, "月給25万円以上"
    assert_includes prompt, "関東（茨城・栃木・群馬・埼玉・千葉・東京・神奈川）"
    assert_includes prompt, companies(:bank).name
  end

  private

  def find_with(text:, searched_urls: [])
    response = { text: text, sources: [], searched_urls: searched_urls }

    Claude.stub(:generate_with_search, response) do
      CompanyFinder.new(industries: [ "商社" ], areas: [], min_salary: 0).call.companies
    end
  end
end
