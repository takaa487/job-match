class EsDraftsController < ApplicationController
  before_action :authenticate_user!

  def index
    @es_drafts = current_user.es_drafts.order(created_at: :desc)
  end

  def create
    company = Company.find(params.expect(:company_id))
    es_draft = current_user.es_drafts.build(company: company, content: params[:content])

    if es_draft.save
      redirect_to company, notice: "ESを保存しました"
    else
      redirect_to company, alert: "ESを保存できませんでした"
    end
  end

  def destroy
    current_user.es_drafts.find(params.expect(:id)).destroy!
    redirect_to es_drafts_path, notice: "ESを削除しました", status: :see_other
  end
end
