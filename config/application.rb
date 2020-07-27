require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'sprockets/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Osb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.autoload_paths += Dir["#{config.root}/lib/"]
    config.assets.enabled = true
    config.autoload_paths += %W(#{config.root}/lib)
    config.action_controller.permit_all_parameters = true
    config.active_record.belongs_to_required_by_default = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.middleware.use I18n::JS::Middleware
    config.to_prepare do
      # Only Applications list
      Doorkeeper::ApplicationsController.layout "doorkeeper"

      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "doorkeeper"

      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout "doorkeeper"
    end

  end
end
