require "test_helper"

class CompanySearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user)
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
