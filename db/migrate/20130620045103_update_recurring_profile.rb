class UpdateRecurringProfile < ActiveRecord::Migration
  def up
    add_column :recurring_profiles, :invoice_number, :string
    add_column :recurring_profiles, :discount_type, :string
    add_column :recurring_profiles, :invoice_total, :decimal, :precision => 10, :scale => 2
    add_column :recurring_profiles, :archive_number, :string
    add_column :recurring_profiles, :archived_at, :datetime
    add_column :recurring_profiles, :deleted_at, :datetime
    add_column :recurring_profiles, :payment_terms_id, :integer
    add_column :recurring_profiles, :company_id, :integer
    add_column :recurring_profiles, :last_invoice_status, :string
    remove_column :recurring_profiles, :tems

    add_column :recurring_profile_line_items, :archive_number, :string
    add_column :recurring_profile_line_items, :archived_at, :datetime
    add_column :recurring_profile_line_items, :deleted_at, :datetime
    rename_column :recurring_profile_line_items, :invoice_id, :recurring_profile_id

  end

  def down
    remove_column :recurring_profiles, :archive_number
    remove_column :recurring_profiles, :invoice_number
    remove_column :recurring_profiles, :archived_at
    remove_column :recurring_profiles, :deleted_at
    remove_column :recurring_profiles, :company_id
    remove_column :recurring_profiles, :payment_terms_id
    remove_column :recurring_profiles, :discount_type
    remove_column :recurring_profiles, :invoice_total
    remove_column :recurring_profiles, :last_invoice_status

    remove_column :recurring_profile_line_items, :archive_number
    remove_column :recurring_profile_line_items, :archived_at
    remove_column :recurring_profile_line_items, :deleted_at
  end
end
