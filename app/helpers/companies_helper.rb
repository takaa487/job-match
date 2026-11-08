module CompaniesHelper
  def salary_text(company)
    return "未登録" if company.starting_salary.blank?
    "#{number_with_delimiter(company.starting_salary)}円"
  end

  def work_location_text(company)
    company.work_location.presence || "未登録"
  end
end
