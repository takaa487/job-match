class EsDraftsController < ApplicationController
  before_action :authenticate_user!

  def index
    # 企業のページへのリンクを出すときに、ES ごとに企業を読みこまないよう、まとめて読みこむ
    @es_drafts = current_user.es_drafts.preload(:company).order(created_at: :desc)
  end

  # ES作成の画面で作った下書きを保存する
  def create
    es_draft = current_user.es_drafts.build(es_draft_params)

    if es_draft.save
      redirect_to es_drafts_path, notice: "ESを保存しました"
    else
      redirect_to new_es_generation_path(company_name: es_draft.company_name), alert: "ESを保存できませんでした"
    end
  end

  def destroy
    current_user.es_drafts.find(params.expect(:id)).destroy!
    redirect_to es_drafts_path, notice: "ESを削除しました", status: :see_other
  end

  private

  def es_draft_params
    params.expect(es_draft: [ :company_name, :content ])
  end
end
