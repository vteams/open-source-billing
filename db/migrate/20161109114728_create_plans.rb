class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :amount
      t.string :interval
      t.integer :trial_period_days
      t.timestamps
    end
  end
end
