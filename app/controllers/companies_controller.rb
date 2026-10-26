class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
   def index
    # まず全企業を取ってくる（検索してないときは、これが一覧に出る）
    @companies = Company.all

    # 検索ボックスに文字が入力されていたら、絞り込みを実行する
    if params[:search].present?
      # 名前 or 業種に、入力された文字を「含む」企業だけに絞る（% は「含む」の意味）
      @companies = @companies.where("name LIKE ? OR industry LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
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
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: [ :name, :industry, :starting_salary, :url, :description ])
    end
end
