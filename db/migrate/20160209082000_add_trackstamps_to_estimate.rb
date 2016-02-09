class AddTrackstampsToEstimate < ActiveRecord::Migration
  def change
    add_column :estimates, :created_by, :integer
    add_column :estimates, :updated_by, :integer
  end
end
