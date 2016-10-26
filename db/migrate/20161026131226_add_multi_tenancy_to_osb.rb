class AddMultiTenancyToOsb < ActiveRecord::Migration
  def self.up
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

  end

  def self.down
        ActiveRecord::Base.connection.tables.each do |table|
      remove_column(table.to_sym, :account_id) if column_exists?(table.to_sym, :account_id)
    end

    remove_column :accounts, :subdomain
    remove_column :accounts, :pp_login
    remove_column :accounts, :pp_password
    remove_column :accounts, :pp_signature
  end
end