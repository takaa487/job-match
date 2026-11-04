class Company < ApplicationRecord
  has_many :company_areas, dependent: :destroy
  has_many :areas, through: :company_areas
end
