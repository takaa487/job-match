class EsDraft < ApplicationRecord
  belongs_to :user
  # 登録されていない企業の ES や、企業が消されたあとの ES もあるので、企業のない ES も許す
  belongs_to :company, optional: true

  before_validation :link_registered_company, on: :create

  validates :company_name, :content, presence: true

  private

  # 登録済みの企業の ES なら、一覧から企業のページへ移れるように、企業ともつないでおく
  def link_registered_company
    self.company ||= Company.find_by(name: company_name)
  end
end
