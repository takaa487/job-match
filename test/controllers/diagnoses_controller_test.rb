require "test_helper"

class DiagnosesControllerTest < ActionDispatch::IntegrationTest
  test "質問の画面は、ログインしなくても見られる" do
    get new_diagnosis_url

    assert_response :success
  end

  test "全部の質問に答えると、結果の画面に移動する" do
    post diagnoses_url, params: { answers: Diagnosis.question_ids.index_with("2") }

    assert_redirected_to diagnosis_url("AMPW")
  end

  test "答えていない質問があると、質問の画面に戻る" do
    post diagnoses_url, params: { answers: Diagnosis.question_ids.index_with("2").except("1") }

    assert_redirected_to new_diagnosis_url
    assert_equal "すべての質問に答えてください", flash[:alert]
  end

  test "ない診断結果を開くと、質問の画面に戻る" do
    get diagnosis_url("XXXX")

    assert_redirected_to new_diagnosis_url
  end

  test "ログインしていないと、タイプは見られるが、向いている業界は見られない" do
    get diagnosis_url("AMPW")

    assert_response :success
    assert_includes response.body, Diagnosis::TYPES["AMPW"][:name]
    assert_not_includes response.body, Diagnosis::TYPES["AMPW"][:industries].first
  end

  test "ログインすると、向いている業界も見られる" do
    sign_in users(:user)

    get diagnosis_url("AMPW")

    assert_includes response.body, Diagnosis::TYPES["AMPW"][:industries].first
  end
end