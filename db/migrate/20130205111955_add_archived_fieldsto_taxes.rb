class AddArchivedFieldstoTaxes < ActiveRecord::Migration
  def up
    add_column :taxes, :archive_number, :string
    add_column :taxes, :archived_at, :datetime
    add_column :taxes, :deleted_at, :datetime
  end

  def down
    remove_column :archive_number, :taxes
    remove_column :archived_at, :taxes
    remove_column :deleted_at, :taxes
  end
end
