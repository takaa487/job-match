require "test_helper"

class CompanySearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user)
  end

  test "AI が探した会社を、一覧に出す" do
    response_from_ai = { text: '[{"name": "テスト商事", "industry": "金融"}]', sources: [], searched_urls: [] }

    with_ai_key do
      Claude.stub(:generate_with_search, response_from_ai) do
        post company_searches_url, params: { industries: [ "金融" ] }
      end
    end

    assert_response :success
    assert_includes response.body, "テスト商事"
  end

  test "業界を選んでいなければ、AI を呼ばずに絞り込みの画面に戻す" do
    with_ai_key do
      post company_searches_url, params: { industries: [] }
    end

    assert_redirected_to filter_companies_url
  end

  test "AI の呼び出しに失敗したら、エラー画面にせず、絞り込みの画面に戻してメッセージを出す" do
    filter_url = filter_companies_url(industries: [ "金融" ])

    with_ai_key do
      Claude.stub(:generate_with_search, ->(*, **) { raise Claude::Error, "テスト用の失敗" }) do
        post company_searches_url, params: { industries: [ "金融" ] }, headers: { "Referer" => filter_url }
      end
    end

    assert_redirected_to filter_url
    assert_equal ApplicationController::AI_FAILED_MESSAGE, flash[:alert]
  end
end
