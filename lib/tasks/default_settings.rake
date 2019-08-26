require 'rake'
namespace :application_settings do
  task :set_default_settings => :environment do
    Settings.delete_all

    Settings.currency = "On"
    Settings.default_currency = "USD"
    Settings.date_format = "%Y-%m-%d"
    Settings.invoice_number_format = "{{invoice_number}}"
  end
end
