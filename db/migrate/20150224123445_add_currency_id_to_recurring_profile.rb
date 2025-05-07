class AddCurrencyIdToRecurringProfile < ActiveRecord::Migration
  def self.up
    unless column_exists?(:recurring_profiles,:currency_id)
      add_column :recurring_profiles, :currency_id, :integer
    end
  end

  def self.down
    if column_exists? :recurring_profiles,:currency_id
      remove_column :recurring_profiles,:currency_id
    end
  end
end
