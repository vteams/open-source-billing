class ChangeDataTypeForRateToTeamMembers < ActiveRecord::Migration
  def change
    change_column :team_members, :rate, :float
  end
end
