class AddProviderToEstimates < ActiveRecord::Migration
  def change
    add_column :estimates, :provider, :string
    add_column :estimates, :provider_id, :string
  end
end
