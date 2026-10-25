class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :industry
      t.integer :starting_salary
      t.string :url
      t.text :description

      t.timestamps
    end
  end
end
