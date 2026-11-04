class Area < ApplicationRecord
  has_many :company_areas, dependent: :destroy
  has_many :companies, through: :company_areas

  validates :name, presence: true, uniqueness: true
end
