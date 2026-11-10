class Company < ApplicationRecord
  has_many :company_areas, dependent: :destroy
  has_many :areas, through: :company_areas

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
