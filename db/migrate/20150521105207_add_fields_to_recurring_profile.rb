class AddFieldsToRecurringProfile < ActiveRecord::Migration[6.0]
  def change
    add_column :recurring_profiles, :created_by, :integer
    add_column :recurring_profiles, :updated_by, :integer
  end
end
