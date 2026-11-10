class EsDraft < ApplicationRecord
  belongs_to :user
  # 企業が消されても ES は残すので、企業のない ES もある
  belongs_to :company, optional: true

  before_validation :copy_company_name, on: :create

  validates :company_name, :content, presence: true

  private

  # 企業が消されたり名前が変わったりしても、どの企業向けの ES だったか分かるように、保存した時点の企業名を写しておく
  def copy_company_name
    self.company_name ||= company&.name
  end
end
