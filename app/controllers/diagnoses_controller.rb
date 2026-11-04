# 就活タイプ診断の画面（質問 → 結果）
class DiagnosesController < ApplicationController
  # 質問画面（/diagnoses/new）
  def new
    @questions = Diagnosis.ordered_questions
  end

  # 答えを受け取って、タイプを出し、結果画面へ移動する
  def create
    answers = params.expect(answers: Diagnosis.question_ids)

    if Diagnosis.all_answered?(answers)
      redirect_to diagnosis_path(Diagnosis.type_code(answers))
    else
      redirect_to new_diagnosis_path, alert: "すべての質問に答えてください"
    end
  end

  # 結果画面（/diagnoses/AMPW のように、URLの最後がタイプ記号）
  def show
    @code = params[:id]
    @type = Diagnosis::TYPES[@code]

    if @type.nil?
      redirect_to new_diagnosis_path, alert: "その診断結果はありません"
      return
    end

    @axis_labels = Diagnosis.axis_labels(@code)
    store_location_for(:user, request.fullpath) unless user_signed_in?
  end
end
