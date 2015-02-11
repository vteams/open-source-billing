# This file is used by Rack-based servers to start the application.
require 'grape/rabl'
require ::File.expand_path('../config/environment',  __FILE__)
run Osb::Application
