class AddCompanyNameToEsDrafts < ActiveRecord::Migration[8.1]
  def change
    add_column :es_drafts, :company_name, :string

    # すでに保存されている ES には、今の企業名を写しておく
    up_only do
      execute "UPDATE es_drafts SET company_name = (SELECT name FROM companies WHERE companies.id = es_drafts.company_id)"
    end

    change_column_null :es_drafts, :company_name, false
    change_column_null :es_drafts, :content, false
    # 企業を消しても ES は残すので、企業のない ES を許す
    change_column_null :es_drafts, :company_id, true
  end
end
