class AddAbbrevationToCompany < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :abbreviation, :string
  end
end
