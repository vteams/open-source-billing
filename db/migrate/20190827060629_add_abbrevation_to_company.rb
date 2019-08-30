class AddAbbrevationToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :abbreviation, :string
  end
end
