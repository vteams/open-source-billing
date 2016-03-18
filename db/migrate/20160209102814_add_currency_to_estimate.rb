class AddCurrencyToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :currency_id, :integer
  end
end
