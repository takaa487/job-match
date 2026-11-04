
class EsDraftsController < ApplicationController
  before_action :authenticate_user!

  def index
    @es_drafts = current_user.es_drafts.order(created_at: :desc)
  end

  def create
    current_user.es_drafts.create(company_id: params[:company_id], content: params[:content])
    redirect_to company_path(params[:company_id]), notice: "ESを保存しました"
  end

  def destroy
    es_draft = current_user.es_drafts.find(params[:id])
    es_draft.destroy
    redirect_to es_drafts_path, notice: "ESを削除しました"
  end
end