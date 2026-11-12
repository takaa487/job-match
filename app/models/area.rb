class Area < ApplicationRecord
  # 地方ごとの都道府県。AI に企業を探してもらうとき、地方の範囲をまちがえさせないために条件と一緒に渡す
  PREFECTURES = {
    "北海道・東北" => "北海道・青森・岩手・宮城・秋田・山形・福島",
    "関東" => "茨城・栃木・群馬・埼玉・千葉・東京・神奈川",
    "中部" => "新潟・富山・石川・福井・山梨・長野・岐阜・静岡・愛知",
    "近畿" => "三重・滋賀・京都・大阪・兵庫・奈良・和歌山",
    "中国・四国" => "鳥取・島根・岡山・広島・山口・徳島・香川・愛媛・高知",
    "九州・沖縄" => "福岡・佐賀・長崎・熊本・大分・宮崎・鹿児島・沖縄"
  }.freeze

  has_many :company_areas, dependent: :destroy
  has_many :companies, through: :company_areas

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true
end
