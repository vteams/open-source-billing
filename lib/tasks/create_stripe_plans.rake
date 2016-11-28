require 'rake'
namespace :stripe do
  desc 'all'
  task all: [:delete_plans,:create_plans, :create_free_plan]

  desc "Create stripe plans"
  task :create_plans => :environment do
    plans = [
        {stripe_plan_id: 'free', name: 'Free Plan', amount: 0, interval: 'day', client_limit: 5},
        {stripe_plan_id: 'silver', name: 'Silver', amount: 4.99, interval: 'month', client_limit: 10},
        {stripe_plan_id: 'gold', name: 'Gold', amount: 199.99, interval: 'month', client_limit: 25},
        {stripe_plan_id: 'platinum', name: 'Platinum', amount: 99.99, interval: 'month', client_limit: 1000}
    ]
    puts " Plans creation in progress..."
    plans.each do |plan|
      if Plan.create!(plan)
        Stripe::Plan.create(
            :amount   => (plan[:amount]*100).to_i,
            :interval => plan[:interval],
            :name     => plan[:name],
            :currency => 'usd',
            :id       => plan[:stripe_plan_id]
        )
      end

    end
    puts " Plans Created ..............................."
  end

  desc "Create test plans to check events"
  task :create_free_plan => :environment do
    plan = {stripe_plan_id: 'free', name: 'Free Plan', amount: 0, interval: 'day', client_limit: 5}
    puts " Plans creation in progress..."
    Plan.create!(plan)
    Stripe::Plan.create(
        :amount   => (plan[:amount]*100),
        :interval => plan[:interval],
        :name     => plan[:name],
        :currency => 'usd',
        :id       => plan[:stripe_plan_id],
        trial_period_days: 360
    )
    puts " Plans Created ..............................."
  end


  desc "Delete stripe/database plans"
  task :delete_plans => :environment do
    Plan.all.each do |plan|
      if plan.destroy
        plan = Stripe::Plan.retrieve(plan.stripe_plan_id)
        plan.delete
      end
    end
    puts " Plans Deleted ..............................."
  end


end
