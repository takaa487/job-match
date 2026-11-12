class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :require_admin, only: %i[ new create edit update destroy ]


  def index
    @companies = Company.search(params[:search])
  end

  def filter
    @industries = Company::INDUSTRIES
    @areas = Area.order(:position)
    # 診断結果の「この業界の企業を見る」から来た時は、タイプの記号（例: AMPW）が付いてくる
    @type_code = params[:type].to_s
    @from_type = Diagnosis::TYPES[@type_code]
    # 何も選ばずに「絞り込む」を押したときも、全部の企業を結果として出すため、searched も見る
    @searched = params.values_at(:searched, :industries, :min_salary, :areas).any?(&:present?)
    return unless @searched

    @companies = Company.in_industries(params[:industries]).with_salary_at_least(params[:min_salary]).in_areas(params[:areas])
  end

  def show
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to @company, notice: "企業を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @company.update(company_params)
      redirect_to @company, notice: "企業の情報を更新しました", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @company.destroy!
    redirect_to companies_path, notice: "企業を削除しました", status: :see_other
  end

  private

  # 管理者以外は、企業の登録・編集・削除をできないようにする
  def require_admin
    redirect_to companies_path, alert: "権限がありません" unless current_user&.admin?
  end

  def set_company
    @company = Company.find(params.expect(:id))
  end

  def company_params
    params.expect(company: [ :name, :industry, :starting_salary, :work_location, :url, :description ])
  end
end
