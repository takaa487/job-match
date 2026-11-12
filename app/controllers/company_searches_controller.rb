# データベースにない企業を、AI に Web 検索で探してもらう画面（結果はデータベースに保存しない）
class CompanySearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ai

  # 絞り込みの画面の「AIでもっと探す」から来る
  def create
    @industries = Array(params[:industries]) & Company::INDUSTRIES
    return redirect_to filter_companies_path if @industries.empty?

    @areas = Area.order(:position).pluck(:name) & Array(params[:areas])
    @min_salary = params[:min_salary].to_i
    result = CompanyFinder.new(industries: @industries, areas: @areas, min_salary: @min_salary).call
    @companies = result.companies
    @sources = result.sources
  end
end
