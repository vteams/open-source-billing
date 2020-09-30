# This file is used by Rack-based servers to start the application.
require ::File.expand_path('../config/environment',  __FILE__)
require 'grape/rabl'
run Osb::Application
Grape::Rabl.configure do |config|
  config.cache_template_loading = true # default: false
end
use Rack::Config do |env|
  env['api.tilt.root'] = 'vendor/engines/osb_api/app/views'
end