require "test_helper"

class EsDraftTest < ActiveSupport::TestCase
  test "登録済みの企業名なら、その企業ともつないで保存する" do
    draft = users(:user).es_drafts.create!(company_name: "サンプル銀行", content: "志望動機")

    assert_equal companies(:bank), draft.company
  end

  test "登録されていない企業の ES も、企業名だけで保存できる" do
    draft = users(:user).es_drafts.create!(company_name: "テスト商事", content: "志望動機")

    assert_nil draft.company
    assert_equal "テスト商事", draft.company_name
  end

  test "企業名か本文が空なら保存できない" do
    draft = users(:user).es_drafts.build(company_name: "", content: "")

    assert_not draft.valid?
    assert draft.errors.of_kind?(:company_name, :blank)
    assert draft.errors.of_kind?(:content, :blank)
  end
end
