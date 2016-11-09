# desc "Explaining what the task does"
namespace :osbm do

 task :admin => :environment do
  account = Account.find_or_create_by(subdomain: 'admin')
  account.update_column(:org_name, 'admin')
  if User.where(email: 'admin@opensourcebilling.org').present?
     user = User.where(email: 'admin@opensourcebilling.org').first
     user.update_attributes(account_id: account.id)
  else
     user = User.create(user_name: 'admin',email: 'admin@opensourcebilling.org',password: 'word2pass',password_confirmation: 'word2pass',account_id: account.id)
     user.confirm!
  end
 end

end
