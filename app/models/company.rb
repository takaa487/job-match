class Company < ApplicationRecord
  # 診断の結果（Diagnosis::TYPES）で使っている業界と同じ8つ
  INDUSTRIES = [
    "メーカー",
    "商社",
    "小売",
    "金融",
    "サービス・インフラ",
    "ソフトウェア・通信",
    "広告・出版・マスコミ",
    "官公庁・公社・団体"
  ].freeze

  has_many :company_areas, dependent: :destroy
  has_many :areas, through: :company_areas
  # 企業を消しても、利用者が保存した ES は残す（ES には企業名を写してある）
  has_many :es_drafts, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :industry, inclusion: { in: INDUSTRIES }
  validates :starting_salary, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  # javascript: のような押すと危ない URL や、途中に改行やスペースが入った URL を入れられないようにするため
  validates :url, format: { with: %r{\Ahttps?://\S+\z} }, allow_blank: true

  # 下の3つは、条件が空なら絞り込まない（scope の中身が nil のとき、Rails は全部の企業を返す）
  scope :in_industries, ->(industries) { where(industry: industries) if industries.present? }
  scope :with_salary_at_least, ->(amount) { where(starting_salary: amount..) if amount.present? }
  scope :in_areas, ->(area_names) { where(id: CompanyArea.joins(:area).where(areas: { name: area_names }).select(:company_id)) if area_names.present? }

  def self.search(keyword)
    return all if keyword.blank?

    # % や _ を「何にでも当てはまる記号」ではなく、ただの文字として探すため
    pattern = "%#{sanitize_sql_like(keyword)}%"
    where(arel_table[:name].matches(pattern, "\\")).or(where(arel_table[:industry].matches(pattern, "\\")))
  end
end
