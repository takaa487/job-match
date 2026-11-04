class CreateCompanyAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :company_areas do |t|
      t.references :company, null: false, foreign_key: true
      t.references :area, null: false, foreign_key: true

      t.timestamps
    end
    add_index :company_areas, [:company_id, :area_id], unique: true
  end
end