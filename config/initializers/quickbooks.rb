oauth_params = {
    site: 'https://appcenter.intuit.com/connect/oauth2',
    authorize_url: 'https://appcenter.intuit.com/connect/oauth2',
    token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
}
APP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env])
::QB_OAUTH2_CONSUMER = OAuth2::Client.new(APP_CONFIG[:OAUTH_CONSUMER_KEY], APP_CONFIG[:OAUTH_CONSUMER_SECRET], oauth_params)
Quickbooks.sandbox_mode = true