class AddMultiTenancyToOsb < ActiveRecord::Migration
  def self.up
    <%= upward_migration -%>
  end

  def self.down
    <%= downward_migration -%>
  end
end