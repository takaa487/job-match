json.extract! company, :id, :name, :industry, :starting_salary, :url, :description, :created_at, :updated_at
json.url company_url(company, format: :json)
