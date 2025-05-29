require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'mail'

class GmailService
  APPLICATION_NAME = 'Open-Source_billing'.freeze
  CREDENTIALS_PATH = File.join(Rails.root, 'config', 'client_secret.json').freeze
  OOB_URI = 'https://market.presstigers.com/oauth2callback'.freeze
  TOKEN_PATH = File.join(Rails.root, 'config', 'gmail_token.yaml').freeze
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND

  attr_reader :service

  def initialize
    @service = Google::Apis::GmailV1::GmailService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

  def send_email(mail)
    email = mail.to_s
    email.prepend "Bcc: #{mail.Bcc.value}\n"
    @service.send_user_message('me', upload_source: StringIO.new(email), content_type: 'message/rfc822')
  end

  private
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)

    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open the following URL in your browser and authorize the application:"
      puts url
      puts "Enter the authorization code:"
      code = gets.chomp
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end

    credentials
  end

end
