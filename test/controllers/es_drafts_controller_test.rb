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

  test "企業のページで作ったESを、企業名と一緒に保存する" do
    assert_difference -> { EsDraft.count }, 1 do
      post es_drafts_url, params: { company_id: companies(:bank).id, content: "銀行への志望動機" }
    end
    assert_redirected_to company_url(companies(:bank))
    assert_equal "サンプル銀行", EsDraft.find_by!(content: "銀行への志望動機").company_name
  end

  test "本文が空のESは保存しない" do
    assert_no_difference -> { EsDraft.count } do
      post es_drafts_url, params: { company_id: companies(:bank).id, content: "" }
    end
    assert_redirected_to company_url(companies(:bank))
    assert_equal "ESを保存できませんでした", flash[:alert]
  end

  test "企業が消されたあとも、保存したESは企業名つきで一覧に出る" do
    companies(:tech).destroy

    get es_drafts_url

    assert_includes response.body, "サンプルソフト"
    assert_includes response.body, es_drafts(:user_draft).content
  end
end
