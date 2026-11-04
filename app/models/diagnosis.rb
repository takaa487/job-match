# 就活タイプ診断のデータと計算（DBは使わない、ただのRubyのクラス）
class Diagnosis
  # 4つの軸。1つの軸ごとに、左（left）か右（right）のどちらかに決まる
  AXES = [
    { key: :challenge, left: { code: "A", label: "挑戦" },   right: { code: "S", label: "安定" } },
    { key: :create,    left: { code: "M", label: "つくる" }, right: { code: "K", label: "ささえる" } },
    { key: :people,    left: { code: "P", label: "人" },     right: { code: "T", label: "モノ・データ" } },
    { key: :range,     left: { code: "W", label: "幅広く" }, right: { code: "D", label: "深く" } }
  ]

  # 答えの選択肢。value が点数（そう思うほど大きい）
  CHOICES = [
    { value: 2,  label: "とてもそう思う" },
    { value: 1,  label: "ややそう思う" },
    { value: 0,  label: "どちらでもない" },
    { value: -1, label: "あまり思わない" },
    { value: -2, label: "全く思わない" }
  ]

  # 質問。axis: どの軸の質問か / side: 「そう思う」ほど左右どちらに寄るか
  QUESTIONS = [
    { id: 1,  axis: :challenge, side: :left,  text: "新しいことに挑戦する時、不安よりワクワクの方が大きい" },
    { id: 2,  axis: :challenge, side: :left,  text: "先が読めない環境でも、変化を楽しめる方だ" },
    { id: 3,  axis: :challenge, side: :left,  text: "大きな結果が出せるなら、多少のリスクがあっても挑戦したい" },
    { id: 4,  axis: :challenge, side: :right, text: "決まったやり方があるなら、それに沿って進めたい" },
    { id: 5,  axis: :challenge, side: :right, text: "長く安心して働けることを、何より大切にしたい" },
    { id: 6,  axis: :create,    side: :left,  text: "0から何かを考えて形にするのが好きだ" },
    { id: 7,  axis: :create,    side: :left,  text: "人とは違うアイデアを出すのが得意だ" },
    { id: 8,  axis: :create,    side: :left,  text: "自分の企画やアイデアで、人を驚かせたい" },
    { id: 9,  axis: :create,    side: :right, text: "今あるやり方をコツコツ良くしていくのが得意だ" },
    { id: 10, axis: :create,    side: :right, text: "目立たなくても、周りがうまく回るように支える役が好きだ" },
    { id: 11, axis: :people,    side: :left,  text: "初めて会う人とも、すぐに打ち解けられる" },
    { id: 12, axis: :people,    side: :left,  text: "人を説得したり、気持ちを動かしたりするのが好きだ" },
    { id: 13, axis: :people,    side: :left,  text: "誰かの相談に乗っている時間が苦にならない" },
    { id: 14, axis: :people,    side: :right, text: "機械やアプリなど、モノの仕組みがどうなっているか気になる" },
    { id: 15, axis: :people,    side: :right, text: "数字やデータを見て、傾向を見つけるのが好きだ" },
    { id: 16, axis: :range,     side: :left,  text: "いろいろな部署や仕事を経験してみたい" },
    { id: 17, axis: :range,     side: :left,  text: "興味が移りやすく、色々なことに手を出したくなる" },
    { id: 18, axis: :range,     side: :left,  text: "広く知っていて、人や話をつなぐのが得意だ" },
    { id: 19, axis: :range,     side: :right, text: "1つのことを、とことん突き詰めるのが得意だ" },
    { id: 20, axis: :range,     side: :right, text: "「この分野ならこの人」と言われる専門家になりたい" }
  ]

  # 16タイプ（名前は仮）。キーは4つの軸の記号を並べたもの
  TYPES = {
    "AMPW" => { name: "ゼロイチ仕掛け人",           description: "新しい企画を、人を巻き込みながら形にする",         industries: [ "広告・出版・マスコミ", "商社" ] },
    "AMPD" => { name: "こだわりプロデューサー",     description: "人の心を動かすものに、とことんこだわる",           industries: [ "広告・出版・マスコミ", "メーカー" ] },
    "AMTW" => { name: "新規事業ハッカー",           description: "技術やデータを武器に、新しい事業をどんどん立ち上げる", industries: [ "ソフトウェア・通信", "商社" ] },
    "AMTD" => { name: "技術の開拓者",               description: "最先端の技術を突き詰めて、新しいモノを生み出す",   industries: [ "ソフトウェア・通信", "メーカー" ] },
    "AKPW" => { name: "現場の推進リーダー",         description: "変化の多い現場で、人をまとめて物事を前に進める",   industries: [ "小売", "商社" ] },
    "AKPD" => { name: "伴走するプロ",               description: "相手の課題に深く入り込んで、成長を支える",         industries: [ "サービス・インフラ", "金融" ] },
    "AKTW" => { name: "仕組み改善の切り込み隊長",   description: "データを使って、いろんな現場の仕組みを素早く良くする", industries: [ "ソフトウェア・通信", "小売" ] },
    "AKTD" => { name: "改善のスペシャリスト",       description: "1つの仕組みを、データで徹底的に磨き上げる",       industries: [ "金融", "ソフトウェア・通信" ] },
    "SMPW" => { name: "みんなの企画屋",             description: "いろんな人の声を集めて、長く使われる企画を生み出す", industries: [ "メーカー", "小売" ] },
    "SMPD" => { name: "想いを形にする職人",         description: "相手を深く理解して、長く愛されるものを丁寧につくる", industries: [ "メーカー", "広告・出版・マスコミ" ] },
    "SMTW" => { name: "堅実なものづくり監督",       description: "品質と計画を大事に、チームでモノを形にする",       industries: [ "メーカー", "サービス・インフラ" ] },
    "SMTD" => { name: "こだわりの技術者",           description: "1つの技術を長く磨いて、確かなモノを生み出す",     industries: [ "メーカー", "ソフトウェア・通信" ] },
    "SKPW" => { name: "みんなの調整役",             description: "いろんな人の間に立って、全体を円滑に回す",         industries: [ "官公庁・公社・団体", "金融" ] },
    "SKPD" => { name: "寄り添うサポーター",         description: "一人ひとりに深く向き合って、長く支える",           industries: [ "金融", "サービス・インフラ" ] },
    "SKTW" => { name: "社会の仕組みの守り手",       description: "社会を支える仕組みを、広い視野で安定して回す",     industries: [ "サービス・インフラ", "官公庁・公社・団体" ] },
    "SKTD" => { name: "正確さの番人",               description: "数字やルールを正確に扱って、ミスなく守り抜く",     industries: [ "金融", "官公庁・公社・団体" ] }
  }

  # 質問IDの一覧（文字列）。フォームから受け取った答えをチェックする時に使う
  def self.question_ids
    QUESTIONS.map { |q| q[:id].to_s }
  end

  # 画面に出す順番。同じ軸の質問が続かないように並べ替える（1,6,11,16,2,7,12,17,...）
  def self.ordered_questions
    QUESTIONS.group_by { |q| q[:axis] }.values.transpose.flatten
  end

  # 全部の質問に、選択肢のどれかで答えているか（未回答や変な値があれば false）
  def self.all_answered?(answers)
    valid_values = CHOICES.map { |c| c[:value].to_s }
    question_ids.all? { |id| valid_values.include?(answers[id]) }
  end

  # 答え（{ "1" => "2", "2" => "-1", ... }）から、タイプの記号（例: "AMPW"）を出す
  def self.type_code(answers)
    AXES.map do |axis|
      left  = average_point(answers, axis[:key], :left)
      right = average_point(answers, axis[:key], :right)
      left >= right ? axis[:left][:code] : axis[:right][:code]
    end.join
  end

  # ある軸の「左寄りの質問」または「右寄りの質問」の平均点
  def self.average_point(answers, axis_key, side)
    questions = QUESTIONS.select { |q| q[:axis] == axis_key && q[:side] == side }
    points = questions.map { |q| answers[q[:id].to_s].to_i }
    points.sum.to_f / points.size
  end

  # タイプの記号から、4つの軸の日本語（例: ["挑戦", "つくる", "人", "幅広く"]）を出す
  def self.axis_labels(code)
    code.chars.each_with_index.map do |char, i|
      axis = AXES[i]
      char == axis[:left][:code] ? axis[:left][:label] : axis[:right][:label]
    end
  end
end