# require all services files
Dir["#{Rails.root}/lib/services/**/*.rb"].each{|f| require f}
require "#{Rails.root}/lib/util.rb"