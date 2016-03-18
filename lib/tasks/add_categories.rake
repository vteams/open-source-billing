require 'rake'
namespace :add_categories do
  task :category => :environment do
    CATEGORIES.each do |category|
      ExpenseCategory.create name: category unless ExpenseCategory.find_by_name category
    end
  end
end