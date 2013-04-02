class AddAvailableCreditToClient < ActiveRecord::Migration
  def change
    add_column :clients, :available_credit, :decimal,:precision => 8, :scale => 2
  end
end
