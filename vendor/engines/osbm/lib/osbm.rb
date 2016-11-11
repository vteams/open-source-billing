require 'osbm/engine'
require 'osbm/account_email_template'
require 'osbm/devise_overrides'

module Osbm

  ENABLED = true
  OPEN_ACCESS = true
  SKIPPED_TABLES = ['accounts', 'account_users','company_entities', 'api_keys', 'delayed_jobs', 'oauth_access_grants', 'oauth_access_tokens', 'oauth_applications', 'schema_migrations', 'settings', 'versions','currencies', 'expense_categories', 'sessions', 'users_roles', 'plans', 'subscriptions']

  extend ActiveSupport::Concern
  included do
    default_scope ->{ where(account_id: current_account_id) }
    before_create do
      self.account_id = current_account_id
    end
  end

  def current_account_id
    Thread.current[:current_account]
  end

  module ClassMethods
    def current_account_id
      Thread.current[:current_account]
    end
  end

end

module ScopedMultiTenant
  # include the extension
  # ActiveRecord::Base.send(:include, MultiTenant)
  class AccountTenant

    def self.include_scoped_account
      ActiveRecord::Base.connection.tables.map do |table|
        unless Osbm::SKIPPED_TABLES.include?(table)
          model = table.capitalize.singularize.camelize.constantize
          model.send(:include, Osbm)
        end
      end

      User.send(:extend, DeviseOverrides)
    end

  end
end
