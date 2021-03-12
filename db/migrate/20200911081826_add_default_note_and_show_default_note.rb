class AddDefaultNoteAndShowDefaultNote < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :default_note, :string
  end
end
