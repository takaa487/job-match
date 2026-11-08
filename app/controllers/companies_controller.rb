class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: %i[ show edit update destroy ]
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :require_ai, only: [ :generate_es ]

  # GET /companies or /companies.json
  def index
    @companies = Company.all

    if params[:search].present?
      @companies = @companies.where("name LIKE ? OR industry LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  # GET /companies/filter
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

  # GET /companies/1 or /companies/1.json
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

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @company.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: "Company was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @company.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy!

    respond_to do |format|
      format.html { redirect_to companies_path, notice: "Company was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # 管理者以外は、企業の登録・編集・削除をできないようにする
    def require_admin
      redirect_to companies_path, alert: "権限がありません" unless current_user&.admin?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: [ :name, :industry, :starting_salary, :url, :description ])
    end
end
