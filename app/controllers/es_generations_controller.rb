class EsGenerationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ai, only: %i[ create ]

  # 失敗しても入力した内容が消えないように、元の画面に戻すのではなく、同じ画面を出し直す
  rescue_from Claude::Error do |error|
    log_ai_failure(error)
    flash.now[:alert] = AI_FAILED_MESSAGE
    render :new, status: :service_unavailable
  end

  # 入力フォームを出すだけ
  def new
    @company_name = params[:company_name].to_s.strip.first(50)
  end

  # 企業名と自分の情報を受け取り、AIにWebで調べさせてからES下書きを作る
  def create
    @company_name = params[:company_name].to_s.strip
    @user_info = params[:user_info].to_s.strip

    if @company_name.empty? || @user_info.empty?
      flash.now[:alert] = "企業名と自分の情報の両方を入れてください"
      render :new, status: :unprocessable_content
      return
    end

    if @company_name.length > 50 || @user_info.length > 1000
      flash.now[:alert] = "企業名は50文字、自分の情報は1000文字までにしてください"
      render :new, status: :unprocessable_content
      return
    end

    prompt = <<~PROMPT
      あなたは就活のES作成を手伝うアシスタントです。
      まずWeb検索で「#{@company_name}」の公式サイトや新卒採用ページを調べ、次の3点を確認してください。
      ・事業内容
      ・新卒採用で求める人物像や、大切にしている価値観
      ・最近の取り組み

      そのうえで、以下の応募者がこの企業に応募するための志望動機を300字程度で書いてください。

      【応募者の情報】
      #{@user_info}

      条件：
      ・Web検索で確認できた事実だけを使い、確認できないことは書かない
      ・応募者本人の言葉として自然な文章にする
      ・記号やマークダウンは使わず、本文だけを書く
    PROMPT

    @result = Claude.generate_with_search(prompt)
    render :new
  end
end
