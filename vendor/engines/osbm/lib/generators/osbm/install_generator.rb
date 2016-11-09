module Osbm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Add MultiTenant functionality to OpenSourceBilling"
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer_file_to_main_application
        copy_file('osbm.rb', 'config/initializers/osbm.rb')
      end


      def inject_before_filter_for_current_account
        path = File.join("app", "controllers", "application_controller.rb")
        inject_into_file(path, :before => "  def _reload_libs\n") do
          <<-RUBY
  before_filter :set_current_account, if: :current_account_required?
  def set_current_account
    if request.subdomain.empty?
      redirect_to '/osbm/home'
    else
      unless Osbm::OPEN_ACCESS
        if Account.where(subdomain: request.subdomain).count == 0
          redirect_to '/osbm/home'
          return
        end
      end
      account = Account.find_by(subdomain: request.subdomain)
      if account.present?
        session[:current_account] = account.id
        Thread.current[:current_account] = session[:current_account]
        Thread.current[:current_subdomain] = request.subdomain
        if request.subdomain == 'admin'
          if params[:controller]!='osbm/admins' and params[:controller] !='devise/sessions'
            redirect_to '/osbm/admin/accounts' and return
          end
        end
      else
        redirect_to '/osbm/home'
      end
    end
  end


          RUBY

        end
      end


      def append_multi_tenant_helper_methods_to_application_controller
        path = File.join("app", "controllers", "application_controller.rb")
        inject_into_file(path, before: "  protected\n") do
          <<-RUBY

  def multi_tenant_enabled?
    if defined? Osbm
      Osbm::ENABLED == true
    else
      false
    end
  end

  helper_method :multi_tenant_enabled?

          RUBY

        end

        inject_into_file(path, after: "  protected\n") do
            <<-RUBY

  def is_home_page?
    if multi_tenant_enabled?
      %w(home landing).include? params[:action]
    else
      false
    end
  end

  def current_account_required?
    multi_tenant_enabled? and !is_home_page?
  end

            RUBY
        end

        inject_into_file(path, after: "before_filter :authenticate_user!" ) do
          ", unless: :is_home_page?"
        end

      end


      def inject_user_subdomain_redirection
        path = File.join("app", "controllers", "devise", "sessions_controller.rb")
        inject_into_file(path, after: "sign_in(resource_name, resource)\n") do
          <<-RUBY
    if multi_tenant_enabled? and current_user
      account = Account.unscoped.find current_user.account_id
      if account.subdomain == 'admin'
        redirect_to '/osbm/admin/accounts'
        return
      else
        unless current_user.account_id == Thread.current[:current_account]
          sign_out
          if Rails.env.development?
            redirect_to request.protocol.to_s + account.subdomain + '.' + request.domain + ':' + request.port.to_s
          else
            redirect_to request.protocol.to_s + account.subdomain + '.' + request.domain
          end
          return
        end
      end
    end
          RUBY
        end
      end


      def inject_hooks_to_account_model
        path = File.join('app', 'models', 'account.rb')
        inject_into_file(path, after: "before_save :change_currency_symbol\n") do
          <<-RUBY
  after_create do
    Thread.current[:current_account] = self.id
    Osbm::AccountEmailTemplate.generate(self.id)
  end
          RUBY
        end
      end

      def mount_multi_tenant_to_main_application
        path = File.join('config', 'routes.rb')
        inject_into_file(path, after: "Osb::Application.routes.draw do\n") do
          <<-RUBY
  mount Osbm::Engine => "/osbm"
          RUBY
        end
      end

      def modify_urls_in_devise_mailer
        path = File.join('app', 'views', 'devise', 'mailer', 'reset_password_instructions.html.erb')
        inject_into_file(path, after: "link_to 'Change my password', edit_password_url(@resource, :reset_password_token => @token") do
          ", subdomain: Account.find_by(id: @resource.account_id).try(:subdomain)"
        end

        path = File.join('app', 'views', 'devise', 'mailer', 'confirmation_instructions.html.erb')
        inject_into_file(path, after: "link_to 'Confirm my account', confirmation_url(@resource, :confirmation_token => @resource.confirmation_token") do
          ", subdomain: Account.find_by(id: @resource.account_id).try(:subdomain)"
        end
      end

      def apply_patch_to_recurring_profiles
        path = File.join('lib', 'services', 'recurring', 'recurring_service.rb')
        inject_into_file(path, after: "invoice = ::Invoice.create({\n") do
          <<-RUBY
                                     account_id: profile.account_id,
          RUBY
        end

        path = File.join('lib', 'services', 'recurring', 'recurring_service.rb')
        inject_into_file(path, after: "::InvoiceLineItem.create({\n") do
          <<-RUBY
                                     account_id: invoice.account_id,
          RUBY
        end

      end

      def add_current_account_helper_to_application_helper
        path = File.join('app', 'helpers', 'application_helper.rb')
        inject_into_file(path, after: "module ApplicationHelper\n") do
          <<-RUBY
  def current_account
    Account.find(session[:current_account])
  end
          RUBY
        end
      end

      def modify_view_templates
        path = File.join('app', 'views', 'devise', 'registrations', 'new.html.erb')
        inject_into_file(path, after: "f.text_field :account,") do
          " :value => current_account.try(:org_name), :readonly => true, "
        end

      end

      def modify_reports_query
        path = File.join('lib', 'reporting', 'reports', 'aged_accounts_receivable.rb')
        inject_into_file(path, before: "aged_invoices = Invoice.find_by_sql(<<-SQL") do

          '        condition +=  "AND invoices.account_id = #{' + 'Thread.current[:current_account]' + '}"' + "\n"


        end
      end

      def modify_paypal_business
        path = File.join('app', 'models', 'invoice.rb')
        gsub_file(path, "OSB::CONFIG::PAYPAL_BUSINESS",  "user.current_account.pp_business")
      end  


      def modify_paypal
        path = File.join('app', 'models', 'account.rb')
        old_method = <<-RUBY
  def self.payment_gateway
    ActiveMerchant::Billing::PaypalGateway.new(
        :login => OSB::CONFIG::PAYPAL_LOGIN,
        :password => OSB::CONFIG::PAYPAL_PASSWORD,
        :signature => OSB::CONFIG::PAYPAL_SIGNATURE
    )
  end
        RUBY

        new_method = <<-RUBY
  def payment_gateway
    ActiveMerchant::Billing::PaypalGateway.new(
        :login => self.pp_login,
        :password => self.pp_password,
        :signature => self.pp_signature
    )
  end
  def self.payment_gateway(account_id)
    Account.find(account_id).payment_gateway
  end
        RUBY
        gsub_file(path, old_method, new_method)

        # Calling new account specific pay
        path = File.join('lib', 'services', 'payment_gateway', 'paypal_service.rb')
        old_method_calling = <<-RUBY
    gateway = Account.payment_gateway
        RUBY

        new_method_calling = <<-RUBY
    gateway = Account.find(@invoice.account_id).payment_gateway
        RUBY

        gsub_file(path, old_method_calling, new_method_calling)



        path = File.join('app', 'views', 'accounts', '_form.html.erb')

        country_field = <<-HTML
          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :country, t('views.common.country') %>
            </div>
            <div class="middle_field">
              <%= f.select :country, COUNTRY_LIST, {:prompt => ""}, {"data-placeholder" => t("views.common.select_a_country"), :class => "chzn-select"} %>
              <%#= f.text_field :country %>
            </div>
          </div>
          <!--field_row-->
        HTML

        paypal_fields = <<-HTML
          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :pp_login, t('views.common.paypal_login') %>
            </div>
            <div class="middle_field">
              <%= f.text_field :pp_login %>
            </div>
          </div>
          <!--field_row-->

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :pp_password, t('views.common.paypal_password') %>
            </div>
            <div class="middle_field">
              <%= f.password_field :pp_password %>
            </div>
          </div>
          <!--field_row-->

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :pp_signature, t('views.common.paypal_signature') %>
            </div>
            <div class="middle_field">
              <%= f.password_field :pp_signature %>
            </div>
          </div>

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :pp_business, t('views.common.paypal_busniess') %>
            </div>
            <div class="middle_field">
              <%= f.password_field :pp_business %>
            </div>
          </div>
          <!--field_row-->
        HTML

        inject_into_file(path, after: country_field) do
          paypal_fields
        end

        path = File.join('app', 'controllers', 'accounts_controller.rb')
        inject_into_file(path, after: "params.require(:account).permit(") do
          ":pp_login, :pp_password, :pp_signature, :pp_business,"
        end

      end

      def inject_company_email_templates_to_dashboard
        path = File.join('app', 'controllers', 'dashboard_controller.rb')

        inject_into_file(path, after: "@current_company_id = get_company_id\n") do
          "    CompanyEmailTemplate.where(parent_type: 'Account', account_id: current_account.id).each {|cet| cet.update_column(:parent_id, cet.account_id)}\n"
        end
      end

=begin
      def customized_mailers
        path = File.join('app', 'models', 'account.rb')

        inject_into_file(path, before: "  def payment_gateway\n") do
          <<-RUBY
  def smtp_settings
    if self.try(:smtp_address).present?
      {
        address: self.smtp_address,
        port: self.smtp_port,
        authentication: self.smtp_authentication.try(:to_sym) || :plain,
        enable_starttls_auto: self.smtp_enable_starttls_auto || true,
        user_name: self.smtp_user_name,
        password: self.smtp_password
      }
    else
       OSB::CONFIG::SMTP_SETTINGS_PROD
    end
  end
          RUBY
        end

        mailers = Dir.glob('app/mailers/*.rb')
        mailers.each do |mailer|
          inject_into_file(mailer, after: "Mailer < ActionMailer::Base\n") do
            <<-RUBY
  account_id = Thread.current[:current_account]
  self.smtp_settings = Account.find(account_id).smtp_settings if account_id.present?

            RUBY
          end
        end


        path = File.join('app', 'views', 'accounts', '_form.html.erb')
        pp_field = <<-HTML
          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :pp_signature, t('views.common.paypal_signature') %>
            </div>
            <div class="middle_field">
              <%= f.password_field :pp_signature %>
            </div>
          </div>
          <!--field_row-->
        HTML

        smtp_fields = <<-HTML
          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :smtp_address, t('views.common.smtp_address') %>
            </div>
            <div class="middle_field">
              <%= f.text_field :smtp_address %>
            </div>
          </div>
          <!--field_row-->

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :smtp_port, t('views.common.smtp_port') %>
            </div>
            <div class="middle_field">
              <%= f.text_field :smtp_port %>
            </div>
          </div>
          <!--field_row-->

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :smtp_authentication, t('views.common.authentication') %>
            </div>
            <div class="middle_field">
              <%= f.text_field :smtp_authentication, value: 'plain' %>
            </div>
          </div>
          <!--field_row-->
          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :smtp_user_name, t('views.common.smtp_user_name') %>
            </div>
            <div class="middle_field">
              <%= f.text_field :smtp_user_name %>
            </div>
          </div>
          <!--field_row-->

          <div class="field_row">
            <div class="label_field left single">
              <%= f.label :smtp_password, t('views.common.smtp_password') %>
            </div>
            <div class="middle_field">
              <%= f.password_field :smtp_password %>
            </div>
          </div>
          <!--field_row-->
        HTML

        inject_into_file(path, after: pp_field) do
          smtp_fields
        end

        path = File.join('app', 'controllers', 'accounts_controller.rb')
        inject_into_file(path, after: "params.require(:account).permit(") do
          ":smtp_address, :smtp_port, :smtp_authentication, :smtp_user_name, :smtp_password, "
        end


      end
=end

    end
  end
end