require 'rake'
namespace :stripe do
  desc "Create stripe plans"
  task :create_plans => :environment do
    plans = [
        {name: 'Silver', amount: 50, interval: 'month'},
        {name: 'Gold', amount: 100, interval: 'month'},
        {name: 'Platinum', amount: 150, interval: 'month'}

    ]
    plans.each do |plan|
      @plan = Plan.create!
      if @plan
        Stripe::Plan.create(
            :amount   => plan[:amount]*100,
            :interval => plan[:interval],
            :name     => plan[:name],
            :currency => 'usd',
            :id       => @plan.id
        )
      end
    end
  end
  puts "******************************************************"
  puts "**************    PLANS CREATED ************"
  puts "******************************************************"
end
