require 'rails/generators/active_record'

class Osbm::MigrationGenerator < ::Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  desc 'Generate migration file required for OSB MulitTenant module'

  def install
    migration_template 'migration.rb', "db/migrate/add_multi_tenancy_to_osb.rb"
  end

  def upward_migration
    <<-RUBY
    ActiveRecord::Base.connection.tables.each do |table|
      add_column(table.to_sym, :account_id, :integer) unless column_exists?(table.to_sym, :account_id)
    end

    add_column :accounts, :subdomain, :string
    add_column :accounts, :pp_login, :text
    add_column :accounts, :pp_password, :text
    add_column :accounts, :pp_signature, :text
    add_column :accounts, :pp_business, :text

    admin_account = Account.create(org_name: "admin", subdomain: "admin")
    admin_user =  User.new(email: "admin@opensourcebilling.org", password: "word2pass", password_confirmation: "word2pass", account_id: admin_account.id) 
    admin_user.skip_confirmation!  
    admin_user.save

    RUBY
  end

  def downward_migration
    <<-RUBY
    ActiveRecord::Base.connection.tables.each do |table|
      remove_column(table.to_sym, :account_id) if column_exists?(table.to_sym, :account_id)
    end

    remove_column :accounts, :subdomain
    remove_column :accounts, :pp_login
    remove_column :accounts, :pp_password
    remove_column :accounts, :pp_signature
    RUBY
  end

  def self.next_migration_number(dirname)
    ActiveRecord::Generators::Base.next_migration_number(dirname)
  end
end