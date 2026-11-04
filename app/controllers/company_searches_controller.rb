# DBに無い会社を、AIにWeb検索で探してもらう（結果はDBに保存しない）
class CompanySearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_ai

  # 地方ごとに、どの都道府県が入るか（AIに地方の範囲をまちがえさせないため）
  AREA_PREFECTURES = {
    "北海道・東北" => "北海道・青森・岩手・宮城・秋田・山形・福島",
    "関東" => "茨城・栃木・群馬・埼玉・千葉・東京・神奈川",
    "中部" => "新潟・富山・石川・福井・山梨・長野・岐阜・静岡・愛知",
    "近畿" => "三重・滋賀・京都・大阪・兵庫・奈良・和歌山",
    "中国・四国" => "鳥取・島根・岡山・広島・山口・徳島・香川・愛媛・高知",
    "九州・沖縄" => "福岡・佐賀・長崎・熊本・大分・宮崎・鹿児島・沖縄"
  }.freeze

  # 絞り込みページの「AIでもっと探す」から来る
  def create
    @industries = Array(params[:industries]) & Company.distinct.pluck(:industry)
    @areas = Area.order(:position).pluck(:name) & Array(params[:areas])
    @min_salary = params[:min_salary].to_i

    if @industries.empty?
      redirect_to filter_companies_path
      return
    end

    known_names = Company.pluck(:name)
    result = Claude.generate_with_search(build_prompt(known_names), max_searches: 5)
    Rails.logger.info("AI企業探しの返事: #{result[:text]}")
    @sources = result[:sources]
    @companies = parse_companies(result[:text], result[:searched_urls], known_names)
  end

  private

  # AIへのお願いの文章
  def build_prompt(known_names)
    salary_condition = @min_salary.positive? ? "月給#{@min_salary / 10_000}万円以上" : "指定なし"
    area_condition =
      if @areas.any?
        @areas.map { |area| "#{area}（#{AREA_PREFECTURES[area]}）" }.join("、") + "のどれかで働く可能性があること"
      else
        "指定なし"
      end

    <<~PROMPT
      あなたは日本の新卒就活生のために企業を探すアシスタントです。
      Web検索を使って、次の条件に合う日本の企業を5社まで探してください。

      条件
      ・業界：#{@industries.join("、")}
      ・新卒（学部卒）の初任給：#{salary_condition}
      ・勤務地：#{area_condition}
      ・新卒採用をしていること
      ・次の会社は入れないこと：#{known_names.join("、")}

      ルール
      ・初任給は、公式の採用ページなどで確認できた学部卒の月給だけを書く。確認できなければ「不明」と書く。
      ・初任給の条件がある時は、条件に合うと確認できた会社を優先し、条件より低いと分かった会社は入れない。
      ・勤務地は、募集要項など公式の採用ページで確認できた新卒の勤務地（本社の場所、主な勤務地、転勤の有無など）を短く書く。確認できなければ「不明」と書く。
      ・勤務地の条件がある時は、その地方で働く可能性があると確認できた会社を優先し、その地方では働かないと分かった会社は入れない。
      ・推測で書かない。検索で確認できたことだけを書く。

      出力
      前置きや説明は書かず、次の形のJSONの配列だけを出力してください。
      [{"name": "会社名", "industry": "業界（条件の業界から1つ）", "summary": "どんな会社か（40字以内）", "salary": "初任給（例: 30万5,000円）または不明", "work_location": "勤務地（例: 本社：大阪／全国転勤あり）または不明", "source_url": "確認に使ったページのURL"}]
    PROMPT
  end

  # AIの返事（JSON）を、画面に出す会社の一覧にする。読み取れなければ空の配列
  def parse_companies(text, searched_urls, known_names)
    json = text.to_s[/\[.*\]/m]
    return [] if json.nil?

    list = JSON.parse(json)
    return [] unless list.is_a?(Array)

    companies = list.filter_map do |item|
      next unless item.is_a?(Hash)

      name = item["name"].to_s.strip
      next if name.empty? || already_in_db?(name, known_names)

      url = item["source_url"].to_s.strip
      {
        name: name,
        industry: item["industry"].to_s,
        summary: item["summary"].to_s,
        salary: item["salary"].to_s.strip.presence || "不明",
        work_location: item["work_location"].to_s.strip.presence || "不明",
        source_url: (url.start_with?("https://", "http://") && searched_urls.include?(url)) ? url : nil
      }
    end
    companies.first(5)
  rescue JSON::ParserError
    []
  end

  # DBにもう入っている会社か（「株式会社」やスペースの違いは無視して比べる）
  def already_in_db?(name, known_names)
    target = name.gsub(/株式会社|\s/, "")
    known_names.any? { |known| known.gsub(/株式会社|\s/, "").include?(target) }
  end
end