class AddArchivedAtFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :archive_number, :string
    add_column :companies, :archived_at, :datetime
    add_column :companies, :deleted_at, :datetime
  end
end
