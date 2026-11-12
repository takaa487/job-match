require "test_helper"

class EsGenerationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user)
  end

  test "AI が使えないときは、AI を呼ばずに準備中と出す" do
    post es_generations_url, params: { company_name: "サンプル商事", user_info: "簿記を勉強しています" }

    assert_redirected_to root_url
    assert_equal "AIの機能は準備中です", flash[:alert]
  end

  test "AI の返事を、ES の下書きとして出す" do
    result = { text: "貴社を志望する理由は", sources: [], searched_urls: [] }

    with_ai_key do
      Claude.stub(:generate_with_search, result) do
        post es_generations_url, params: { company_name: "サンプル商事", user_info: "簿記を勉強しています" }
      end
    end

    assert_response :success
    assert_includes response.body, "貴社を志望する理由は"
  end

  test "AI の呼び出しに失敗しても、入力した内容を残したまま、メッセージを出す" do
    with_ai_key do
      Claude.stub(:generate_with_search, ->(*, **) { raise Claude::Error, "テスト用の失敗" }) do
        post es_generations_url, params: { company_name: "サンプル商事", user_info: "簿記を勉強しています" }
      end
    end

    assert_response :service_unavailable
    assert_includes response.body, ApplicationController::AI_FAILED_MESSAGE
    assert_includes response.body, "簿記を勉強しています"
  end
end
