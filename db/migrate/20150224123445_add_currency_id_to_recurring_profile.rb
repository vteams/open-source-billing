class AddCurrencyIdToRecurringProfile < ActiveRecord::Migration
  def change
    add_column :recurring_profiles, :currency_id, :integer
  end
end
