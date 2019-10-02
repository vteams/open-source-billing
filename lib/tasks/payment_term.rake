require 'rake'
namespace :payment_term do
  task :create_payment_term => :environment do
    PaymentTerm.create(number_of_days: 0, description: "Due on received")
    term = PaymentTerm.where(description: 'custom')
    term.update_all(number_of_days: -1)
  end
end