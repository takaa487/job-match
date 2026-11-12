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

  test "登録済みの企業のESは、一覧から企業のページへ移れる" do
    get es_drafts_url

    assert_select "a[href=?]", company_path(companies(:tech)), text: "サンプルソフト"
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

  test "登録されていない企業のESも保存して、保存したESの一覧で「保存しました」と出す" do
    assert_difference -> { users(:user).es_drafts.count }, 1 do
      post es_drafts_url, params: { es_draft: { company_name: "テスト商事", content: "テスト商事への志望動機" } }
    end
    assert_redirected_to es_drafts_url

    follow_redirect!
    assert_select ".alert-success", "ESを保存しました"
    assert_includes response.body, "テスト商事への志望動機"
  end

  test "本文が空のESは保存せず、企業名を入れたままES作成の画面へ戻す" do
    assert_no_difference -> { EsDraft.count } do
      post es_drafts_url, params: { es_draft: { company_name: "サンプル銀行", content: "" } }
    end
    assert_redirected_to new_es_generation_url(company_name: "サンプル銀行")
    assert_equal "ESを保存できませんでした", flash[:alert]
  end

  test "企業が消されたあとも、保存したESは企業名つきで一覧に出る" do
    companies(:tech).destroy

    get es_drafts_url

    assert_includes response.body, es_drafts(:user_draft).content
    # 企業のページはもうないので、リンクにせず名前だけ出す
    assert_select "h5", "サンプルソフト"
    assert_select "a", text: "サンプルソフト", count: 0
  end
end
