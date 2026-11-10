require "test_helper"

class EsDraftTest < ActiveSupport::TestCase
  test "保存するとき、その時点の企業名を ES に写す" do
    draft = users(:user).es_drafts.create!(company: companies(:bank), content: "志望動機")

    assert_equal "サンプル銀行", draft.company_name
  end

  test "本文が空なら保存できない" do
    draft = users(:user).es_drafts.build(company: companies(:bank), content: "")

    assert_not draft.valid?
    assert draft.errors.of_kind?(:content, :blank)
  end
end
