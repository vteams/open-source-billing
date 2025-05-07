class AddFieldsToRecurringProfile < ActiveRecord::Migration
  def change
    add_column :recurring_profiles, :created_by, :integer
    add_column :recurring_profiles, :updated_by, :integer
  end
end
