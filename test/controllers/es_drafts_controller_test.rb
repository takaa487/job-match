require "test_helper"

class EsDraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user)
  end

  test "自分が保存したESだけを一覧に出す" do
    get es_drafts_url

    assert_includes response.body, es_drafts(:user_draft).content
    assert_not_includes response.body, es_drafts(:admin_draft).content
  end

  test "自分が保存したESは消せる" do
    assert_difference -> { EsDraft.count }, -1 do
      delete es_draft_url(es_drafts(:user_draft))
    end
    assert_redirected_to es_drafts_url
  end

  test "ほかの人が保存したESは消せない" do
    assert_no_difference -> { EsDraft.count } do
      delete es_draft_url(es_drafts(:admin_draft))
    end
    assert_response :not_found
  end
end