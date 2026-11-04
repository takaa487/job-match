class CreateEsDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :es_drafts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.text :content

      t.timestamps
    end
  end
end
