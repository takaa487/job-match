# データベースにない企業を、AI に Web 検索で探してもらう（結果はデータベースに保存しない）
class CompanyFinder
  MAX_COMPANIES = 5

  Result = Data.define(:companies, :sources)

  def initialize(industries:, areas:, min_salary:)
    @industries = industries
    @areas = areas
    @min_salary = min_salary
  end

  def call
    known_names = Company.pluck(:name)
    response = Claude.generate_with_search(prompt(known_names), max_searches: MAX_COMPANIES)
    Result.new(companies: parse(response, known_names), sources: response[:sources])
  end

  private

  def prompt(known_names)
    <<~PROMPT
      あなたは日本の新卒就活生のために企業を探すアシスタントです。
      Web検索を使って、次の条件に合う日本の企業を#{MAX_COMPANIES}社まで探してください。

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

  def salary_condition
    @min_salary.positive? ? "月給#{@min_salary / 10_000}万円以上" : "指定なし"
  end

  def area_condition
    return "指定なし" if @areas.empty?

    @areas.map { |area| "#{area}（#{Area::PREFECTURES[area]}）" }.join("、") + "のどれかで働く可能性があること"
  end

  # AI の返事の中の JSON の配列を、画面に出す会社の一覧にする。読み取れなければ空の一覧
  def parse(response, known_names)
    json = response[:text].to_s[/\[.*\]/m]
    list = json ? JSON.parse(json) : []
    return [] unless list.is_a?(Array)

    list.filter_map { |item| to_company(item, response[:searched_urls], known_names) }.first(MAX_COMPANIES)
  rescue JSON::ParserError
    Rails.logger.warn("AIの返事を読み取れませんでした: #{response[:text]}")
    []
  end

  def to_company(item, searched_urls, known_names)
    return unless item.is_a?(Hash)

    name = item["name"].to_s.strip
    return if name.empty? || registered?(name, known_names)

    url = item["source_url"].to_s.strip
    {
      name: name,
      industry: item["industry"].to_s,
      summary: item["summary"].to_s,
      salary: item["salary"].to_s.strip.presence || "不明",
      work_location: item["work_location"].to_s.strip.presence || "不明",
      # AI がそれらしい URL を作ってしまうことがあるので、検索で実際に見たページだけを出典にする
      source_url: searched_urls.include?(url) ? url : nil
    }
  end

  # 「株式会社」やスペース（全角も）の違いは無視して、もう登録されている会社か比べる
  def registered?(name, known_names)
    target = normalize(name)
    known_names.any? { |known| normalize(known).include?(target) }
  end

  def normalize(name)
    name.gsub(/株式会社|[[:space:]]/, "")
  end
end
