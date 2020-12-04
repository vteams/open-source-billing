class AddDefaultNoteAndShowDefaultNote < ActiveRecord::Migration
  def change
    add_column :companies, :default_note, :string
  end
end
