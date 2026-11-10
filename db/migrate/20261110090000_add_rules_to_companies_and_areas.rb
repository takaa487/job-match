class AddRulesToCompaniesAndAreas < ActiveRecord::Migration[8.1]
  def change
    change_column_null :companies, :name, false
    change_column_null :companies, :industry, false
    add_index :companies, :name, unique: true

    change_column_null :areas, :name, false
    change_column_null :areas, :position, false
  end
end
