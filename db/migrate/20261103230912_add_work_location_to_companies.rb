class AddWorkLocationToCompanies < ActiveRecord::Migration[8.1]
  def change
    add_column :companies, :work_location, :string
  end
end
