class CompanyArea < ApplicationRecord
  belongs_to :company
  belongs_to :area

  validates :area_id, uniqueness: { scope: :company_id }
end
