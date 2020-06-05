class AddIsReadToActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :activities, :is_read, :boolean, default: false
  end
end
