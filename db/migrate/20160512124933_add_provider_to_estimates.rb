class AddProviderToEstimates < ActiveRecord::Migration[6.0]
  def change
    add_column :estimates, :provider, :string
    add_column :estimates, :provider_id, :string
  end
end
