module OsbApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      desc "Add MultiTenant functionality to OpenSourceBilling"
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer_file_to_main_application
        copy_file('doorkeeper.rb', 'config/initializers/doorkeeper.rb')
      end

      def mount_osb_api_to_main_application
        path = File.join('config', 'routes.rb')
        inject_into_file(path, after: "Osb::Application.routes.draw do\n") do
          <<-RUBY
  mount OsbApi::Engine => "/api"
  use_doorkeeper
          RUBY
        end
      end


    end
  end
end