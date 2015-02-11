class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :title
      t.string :code
      t.string :unit

      t.timestamps
    end
  end
end
