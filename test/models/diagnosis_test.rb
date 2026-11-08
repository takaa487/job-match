require "test_helper"

class DiagnosisTest < ActiveSupport::TestCase
  test "左の質問にそう思うほど左の記号、右の質問にそう思うほど右の記号になる" do
    assert_equal "AMPW", Diagnosis.type_code(answers(left: "2", right: "-2"))
    assert_equal "SKTD", Diagnosis.type_code(answers(left: "-2", right: "2"))
  end

  test "左右が同じ点なら、左の記号にする" do
    assert_equal "AMPW", Diagnosis.type_code(answers(left: "0", right: "0"))
  end

  test "質問の数が左（3問）と右（2問）で違うので、合計ではなく平均で比べる" do
    # 挑戦の軸：合計は左4・右3で左が大きいが、平均は左1.33・右1.5で右が大きい
    challenge = { "1" => "2", "2" => "2", "3" => "0", "4" => "2", "5" => "1" }

    assert_equal "SMPW", Diagnosis.type_code(answers(left: "0", right: "0").merge(challenge))
  end

  test "全部の質問に、選択肢のどれかで答えたときだけ、答え終わったとみなす" do
    assert Diagnosis.all_answered?(answers(left: "2", right: "-2"))
    assert_not Diagnosis.all_answered?(answers(left: "2", right: "-2").except("1"))
    assert_not Diagnosis.all_answered?(answers(left: "2", right: "-2").merge("1" => "3"))
  end

  test "全部の質問を、同じ軸の質問が続かないように並べる" do
    questions = Diagnosis.ordered_questions

    assert_equal Diagnosis::QUESTIONS.map { |question| question[:id] }.sort, questions.map { |question| question[:id] }.sort
    assert questions.each_cons(2).none? { |before, after| before[:axis] == after[:axis] }
  end

  test "4つの軸のすべての組み合わせに、タイプがある" do
    codes_per_axis = Diagnosis::AXES.map { |axis| [ axis[:left][:code], axis[:right][:code] ] }
    all_codes = codes_per_axis.first.product(*codes_per_axis.drop(1)).map(&:join)

    assert_equal all_codes.sort, Diagnosis::TYPES.keys.sort
  end

  test "タイプの記号から、4つの軸の言葉を出す" do
    assert_equal [ "挑戦", "つくる", "人", "幅広く" ], Diagnosis.axis_labels("AMPW")
  end

  private

  def answers(left:, right:)
    Diagnosis::QUESTIONS.to_h { |question| [ question[:id].to_s, question[:side] == :left ? left : right ] }
  end
end
