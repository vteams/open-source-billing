class AddSendDateToProfile < ActiveRecord::Migration
  def change
    add_column :recurring_profiles, :last_sent_date, :datetime
    add_column :recurring_profiles, :sent_invoices, :integer
    add_column :delayed_jobs, :recurring_profile_id, :integer
  end
end
