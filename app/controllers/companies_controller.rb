class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :require_admin, only: %i[ new create edit update destroy ]
  before_action :require_ai, only: %i[ generate_es ]

  def index
    @companies = Company.all

    if params[:search].present?
      @companies = @companies.where("name LIKE ? OR industry LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def filter
    @industries = Company.distinct.pluck(:industry).compact.sort
    @areas = Area.order(:position)
    # 診断結果の「この業界の企業を見る」から来た時は、タイプの記号（例: AMPW）が付いてくる
    @type_code = params[:type].to_s
    @from_type = Diagnosis::TYPES[@type_code]
    @searched = params[:searched].present? || params[:industries].present? || params[:min_salary].present? || params[:areas].present?
    return unless @searched

    @companies = Company.all
    if params[:industries].present?
      @companies = @companies.where(industry: params[:industries])
    end
    if params[:min_salary].present?
      @companies = @companies.where("starting_salary >= ?", params[:min_salary])
    end
    if params[:areas].present?
      @companies = @companies.joins(:areas).where(areas: { name: params[:areas] }).distinct
    end
  end

  def show
  end

  def generate_es
    @company = Company.find(params[:id])

    prompt = <<~PROMPT
      あなたは就活のES作成を手伝うアシスタントです。
      以下の企業に応募する学生のために、志望動機の下書きを作成してください。

      【企業情報】
      企業名: #{@company.name}
      業種: #{@company.industry}
      特徴: #{@company.description}

      【応募者の情報】
      #{params[:user_info]}

      上記をもとに、この企業への志望動機を300字程度で、応募者本人の言葉として自然に書いてください。
    PROMPT

    @es = Claude.generate(prompt)
    render :show
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
