# 企業の初期データ（bin/rails db:seed で入る）
# 同じ名前の会社がもうあれば上書き、無ければ新しく作るので、何回流しても会社は増えない。
# 初任給（starting_salary）は「学部卒の月給（円）」。各社の公式採用ページ（または公式を引用した就活サイト）で確認した金額。
# 年度・コース・含まれる手当は会社ごとに違うので、description の最後に書いておく。初任給は毎年変わるので、年に1回は見直す。
companies = [
  # ===== メーカー =====
  {
    name: "トヨタ自動車",
    industry: "メーカー",
    starting_salary: 275_000,
    url: "https://www.toyota-recruit.com/saiyo/recruit/info/",
    description: "自動車メーカー。トヨタ・レクサスブランドの車をつくり、世界中で販売している。初任給は事務職・技術職（総合職）の学部卒、2027年入社向け募集要項の金額（2025年度実績）。"
  },
  {
    name: "ソニー",
    industry: "メーカー",
    starting_salary: 323_000,
    url: "https://www.sony.com/ja/SonyInfo/Jobs/newgrads/info/requirements/group/",
    description: "エレクトロニクス、ゲーム、音楽、映画、半導体などを手がけるソニーグループの合同新卒採用。初任給は大学卒、2027年入社向け募集要項の金額（2026年度予定、この金額から）。"
  },
  {
    name: "味の素",
    industry: "メーカー",
    starting_salary: 291_000,
    url: "https://www.ajinomoto.co.jp/company/jp/recruit/fresh/recruit/requirements.html",
    description: "調味料や加工食品の食品メーカー。アミノ酸の技術を、医薬や電子材料の分野にも広げている。初任給は学士卒（全職種共通）、2027年4月入社向け募集要項の金額（2026年4月時点）。"
  },

  # ===== 商社 =====
  {
    name: "三菱商事",
    industry: "商社",
    starting_salary: 340_000,
    url: "https://www.career-mc.com/newgraduate/recruit/requirement.html",
    description: "総合商社。エネルギー、金属資源、食品、自動車など幅広い分野で、事業投資と取引を行う。初任給は学士卒、2027年入社向け募集要項の金額（2025年度実績）。"
  },
  {
    name: "伊藤忠商事",
    industry: "商社",
    starting_salary: 360_000,
    url: "https://career.itochu.co.jp/student/information/",
    description: "総合商社。繊維や食料など、生活に身近な分野に強い。初任給は総合職の大卒、2028年度新卒採用の募集要項の金額（入社後3か月の試用期間中は34万円）。"
  },
  {
    name: "三井物産",
    industry: "商社",
    starting_salary: 340_000,
    url: "https://career.mitsui.com/recruit/recruit/",
    description: "総合商社。資源・エネルギーに強く、インフラ、化学品、食料、ヘルスケアなどにも事業を広げている。初任給は学卒のGlobalコース、2027年入社向け募集要項の金額（Regionalコースは33万円）。"
  },

  # ===== 小売 =====
  {
    name: "ファーストリテイリング",
    industry: "小売",
    starting_salary: 370_000,
    url: "https://www.fastretailing.com/employment/ja/fastretailing/jp/graduate/recruit/",
    description: "ユニクロ、ジーユーなどを世界で展開するアパレル企業。初任給は大卒のグローバルリーダー候補、2026年7月時点の採用ページの金額（地域正社員は28万円）。"
  },
  {
    name: "ニトリ",
    industry: "小売",
    starting_salary: 305_000,
    url: "https://www.nitori.co.jp/recruit/newgraduate/recruitinfo/",
    description: "家具・インテリア用品の会社。商品の企画から製造、物流、販売までを自社で行う。初任給は4年制大学卒、2027年入社向け募集要項の金額。"
  },
  {
    name: "セブン-イレブン・ジャパン",
    industry: "小売",
    starting_salary: 270_000,
    url: "https://www.sej.co.jp/recruit/new/",
    description: "コンビニエンスストア「セブン-イレブン」を全国に展開する。初任給は大学卒、2027年入社向け募集要項の金額（2025年5月実績）。"
  },

  # ===== 金融 =====
  {
    name: "三菱UFJ銀行",
    industry: "金融",
    starting_salary: 300_000,
    url: "https://www.bk.mufg.jp/",
    description: "三菱UFJフィナンシャル・グループの中核の銀行。個人や企業向けに預金、融資、決済などを行う。初任給は大卒（2026年度実績、基本給27万円＋シニアライフプラン支援金3万円）。"
  },
  {
    name: "東京海上日動火災保険",
    industry: "金融",
    starting_salary: 293_780,
    url: "https://www.saiyou.tokiomarine-nichido.co.jp/recruiting/oubo/",
    description: "損害保険会社。自動車保険、火災保険、企業向けの保険などを扱う。初任給は4年制大学卒で転居転勤なしの場合、2027年入社向け募集要項の金額（Myチャレンジ・インセンティブ2万円を含む。転居転勤ありは39万3,780円〜42万7,780円）。"
  },
  {
    name: "日本生命保険",
    industry: "金融",
    starting_salary: 345_500,
    url: "https://www.nissay-saiyo.com/data/recruit/core_eigyo.html",
    description: "生命保険会社。個人向けの保険のほか、企業向けの保険や資産運用も行う。初任給は総合基幹職マネジメントコース（全国転勤型）の大卒、2027年入社向け募集要項の金額（拠点長候補職手当7万4,500円を含む）。"
  },

  # ===== サービス・インフラ =====
  {
    name: "JR東日本",
    industry: "サービス・インフラ",
    starting_salary: 310_000,
    url: "https://recruit.jreast.co.jp/general_position/",
    description: "関東・東北・甲信越などの鉄道を運営する。駅ビルやSuicaなどの生活サービスも手がける。初任給は総合職の大学卒で東京23区内勤務の場合、2027年入社向け募集要項の金額。"
  },
  {
    name: "ANA（全日本空輸）",
    industry: "サービス・インフラ",
    starting_salary: 273_490,
    url: "https://www.ana.co.jp/group/recruit/ana-recruit/occupation/entry/",
    description: "国内線・国際線の航空会社。初任給はグローバルスタッフ職の大卒、2027年4月入社向け募集要項の金額（2026年度予定）。"
  },
  {
    name: "オリエンタルランド",
    industry: "サービス・インフラ",
    starting_salary: 272_000,
    url: "https://www.recruit.olc.co.jp/recruitinfo/",
    description: "東京ディズニーランド・東京ディズニーシーを運営する。初任給は総合職の大卒、2026年4月1日時点の採用ページの金額。"
  },

  # ===== ソフトウェア・通信 =====
  {
    name: "NTTデータ",
    industry: "ソフトウェア・通信",
    starting_salary: 300_000,
    url: "https://nttdata-recruit.com/recruit/requirements.html",
    description: "システムの会社。官公庁・金融・企業向けの大きなシステムを開発・運用する。初任給は学士卒、2027年入社向け募集要項の金額（2026年4月の予定額）。"
  },
  {
    name: "LINEヤフー",
    industry: "ソフトウェア・通信",
    starting_salary: 434_000,
    url: "https://www.lycorp.co.jp/ja/recruit/newgrads/engineer/jd0001/",
    description: "LINE、Yahoo! JAPANなどのインターネットサービスを運営する。初任給はエンジニア職（Software Engineering Specialist）、2028年度入社向け募集要項の金額（月35時間分の固定残業代9.8万円を含む）。"
  },
  {
    name: "NTTドコモ",
    industry: "ソフトウェア・通信",
    starting_salary: 342_000,
    url: "https://information.nttdocomo-fresh.jp/fresh/recruit/outline/",
    description: "携帯電話などの通信サービスを提供し、dポイントや決済などのサービスも手がける。初任給は大学卒、2027年入社向け募集要項の金額（独身・首都圏の場合の住宅補助4万2,000円を含む）。"
  },

  # ===== 広告・出版・マスコミ =====
  {
    name: "博報堂",
    industry: "広告・出版・マスコミ",
    starting_salary: 300_000,
    url: "https://hakusuku.jp/recruit/information/entry/",
    description: "広告会社。広告の企画・制作や、企業のマーケティングを支援する。初任給は年俸制で年俸360万円（月30万円にあたる）、2027年入社向け募集要項の金額（2025年度実績。残業代は別に支給、業績賞与あり）。"
  },
  {
    name: "集英社",
    industry: "広告・出版・マスコミ",
    starting_salary: 283_230,
    url: "https://www.shueisha.co.jp/saiyo/requirements/",
    description: "出版社。「週刊少年ジャンプ」などのマンガ雑誌や書籍、ファッション誌などを発行する。初任給は大卒（22歳の本給）、2027年入社向け募集要項の金額（2025年度実績。6か月の試用期間中は26万9,300円）。"
  },
  {
    name: "サイバーエージェント",
    industry: "広告・出版・マスコミ",
    starting_salary: 420_000,
    url: "https://www.cyberagent.co.jp/careers/about/",
    description: "インターネット広告、メディア（ABEMAなど）、ゲームの事業を手がける。初任給はビジネスコースの月給42万円（年俸504万円）、2028年入社向けの金額（固定残業代として時間外80時間・深夜46時間分を含む）。"
  },

  # ===== 官公庁・公社・団体 =====
  {
    name: "東京都（都庁）",
    industry: "官公庁・公社・団体",
    starting_salary: 242_000,
    url: "https://www.saiyou.metro.tokyo.lg.jp/",
    description: "東京都の行政を担う。都の職員は地方公務員。初任給は1類（大学卒）の一般行政職、2026年4月1日現在の金額（東京都「都職員の給与の状況」より）。"
  },
  {
    name: "JICA（国際協力機構）",
    industry: "官公庁・公社・団体",
    starting_salary: 280_258,
    url: "https://www.jica.go.jp/recruit/shokuin/new-graduate/recruiting.html",
    description: "政府開発援助（ODA）を行う独立行政法人。途上国の開発や人づくりを支援する。初任給は大卒、2027年入社向け募集要項の金額（2025年度実績。東京都勤務の場合の特別都市手当を含む）。"
  },
  {
    name: "JETRO（日本貿易振興機構）",
    industry: "官公庁・公社・団体",
    starting_salary: 292_980,
    url: "https://www.jetro.go.jp/recruit/info/recruitment/requirements.html",
    description: "日本企業の海外展開や、海外から日本への投資を支援する独立行政法人。初任給は総合職の大卒（2025年度実績。東京都勤務の場合の特別都市手当を含む）。"
  }
]

companies.each do |data|
  company = Company.find_or_initialize_by(name: data[:name])
  company.update!(data)
end

puts "企業データを#{companies.size}社入れました（DBの企業は全部で#{Company.count}社）"

# ===== 勤務地（地方）=====
# 地方の一覧（北から南の順）。この順番が position（並び順の番号）になる
area_names = ["北海道・東北", "関東", "中部", "近畿", "中国・四国", "九州・沖縄"]
area_names.each.with_index(1) do |name, position|
  Area.find_or_initialize_by(name: name).update!(position: position)
end

# 会社ごとの勤務地。text はカードに出す文、areas は絞り込みで出す地方（area_names は6地方すべて＝全国）
work_locations = [
  { name: "トヨタ自動車", text: "本社：愛知県豊田市（東京本社・名古屋オフィスもあり）／国内各事業所・海外事業所", areas: ["関東", "中部"] },
  { name: "ソニー", text: "東京（ソニーシティ・ソニーシティ大崎）", areas: ["関東"] },
  { name: "味の素", text: "本社：東京／国内外に転勤の可能性あり（グローバル型）", areas: area_names },
  { name: "三菱商事", text: "本店：東京（入社時は原則首都圏）／国内・海外の拠点や事業会社", areas: area_names },
  { name: "伊藤忠商事", text: "入社時は東京・横浜／その後は国内・海外全域", areas: area_names },
  { name: "三井物産", text: "本店：東京／全国各地・海外", areas: area_names },
  { name: "ファーストリテイリング", text: "全国の直営店舗（全国転勤あり・将来は海外勤務の可能性あり）", areas: area_names },
  { name: "ニトリ", text: "本社：札幌（本部：東京・大阪）／全国の店舗・物流拠点", areas: area_names },
  { name: "セブン-イレブン・ジャパン", text: "全国転勤あり（47都道府県の出店エリア）", areas: area_names },
  { name: "三菱UFJ銀行", text: "コースにより異なる（全国・海外／国内ブロック内／転居なし）", areas: area_names },
  { name: "東京海上日動火災保険", text: "本店：東京／日本全国・世界全域", areas: area_names },
  { name: "日本生命保険", text: "本店：大阪／全国転勤あり（マネジメントコース）", areas: area_names },
  { name: "JR東日本", text: "東日本エリアの事業所（東北・関東・甲信越など）・海外の事業所", areas: ["北海道・東北", "関東", "中部"] },
  { name: "ANA（全日本空輸）", text: "国内外の各事業所", areas: area_names },
  { name: "オリエンタルランド", text: "千葉県（転勤なし）", areas: ["関東"] },
  { name: "NTTデータ", text: "主に首都圏／業務により関西などの国内拠点・海外拠点", areas: ["関東", "近畿"] },
  { name: "LINEヤフー", text: "東京・紀尾井町（オフィスかリモートを選べる）", areas: ["関東"] },
  { name: "NTTドコモ", text: "ドコモグループの国内外の事業所", areas: area_names },
  { name: "博報堂", text: "本社：東京・赤坂／関西支社・中部支社・海外の事業所", areas: ["関東", "中部", "近畿"] },
  { name: "集英社", text: "本社：東京・千代田区", areas: ["関東"] },
  { name: "サイバーエージェント", text: "本社：東京・渋谷（大阪・名古屋・福岡にも拠点）※エンジニア・デザイナーは原則東京", areas: ["関東", "中部", "近畿", "九州・沖縄"] },
  { name: "東京都（都庁）", text: "東京都内", areas: ["関東"] },
  { name: "JICA（国際協力機構）", text: "本部（東京）・国内15拠点・海外96拠点（海外赴任は必須）", areas: area_names },
  { name: "JETRO（日本貿易振興機構）", text: "最初は原則本部（東京）／国内の拠点・海外の事務所", areas: area_names }
]

work_locations.each do |data|
  company = Company.find_by(name: data[:name])
  if company.nil?
    puts "見つからなかった会社: #{data[:name]}"
    next
  end

  areas = Area.where(name: data[:areas])
  puts "地方名の書きまちがい: #{data[:name]}" if areas.size != data[:areas].size

  company.update!(work_location: data[:text])
  company.areas = areas
end

puts "勤務地を登録した会社: #{Company.where.not(work_location: nil).count}社"