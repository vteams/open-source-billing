require 'rake'
namespace :stripe do
  desc 'all'
  task all: [:create_plans, :create_plans_with_trial]

  desc "Create stripe plans"
  task :create_plans => :environment do
    plans = [
        {name: 'Silver', amount: 50, interval: 'month'},
        {name: 'Gold', amount: 100, interval: 'month'},
        {name: 'Platinum', amount: 150, interval: 'month'}

    ]
    plans.each do |plan|
      @plan = Plan.create!(plan)
      if @plan
        Stripe::Plan.create(
            :amount   => (@plan[:amount]*100),
            :interval => @plan[:interval],
            :name     => @plan[:name],
            :currency => 'usd',
            :id       => @plan.id
        )
      end
      puts "******************************************************"
      puts "**************  #{@plan.name} has been created! ************"
      puts "******************************************************"
    end
  end

  desc "Create test plans to check events"
  task :create_plans_with_trial => :environment do
    plan = {name: 'Test Plan', amount: 100, interval: 'day'}
    @plan= Plan.create!(plan)
    if Stripe::Plan.create(
        :amount   => (@plan[:amount]*100),
        :interval => @plan[:interval],
        :name     => @plan[:name],
        :currency => 'usd',
        :id       => @plan.id,
        trial_period_days: 7
    )
      puts "******************************************************"
      puts "**************  #{@plan.name} has been created! ************"
      puts "******************************************************"
    end
  end


end
