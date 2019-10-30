require 'rake'
namespace :destroy_activities do
  task :destroy_activities_notifications => :environment do
    PublicActivity::Activity.where("activities.key LIKE ?", "%destroy%").destroy_all
    PublicActivity::Activity.where("activities.key LIKE ?", "%payment.update%").destroy_all
  end
end