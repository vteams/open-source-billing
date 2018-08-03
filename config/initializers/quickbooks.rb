oauth_params = {
    site: 'https://appcenter.intuit.com/connect/oauth2',
    authorize_url: 'https://appcenter.intuit.com/connect/oauth2',
    token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
}
::QB_OAUTH2_CONSUMER = OAuth2::Client.new(OSB::CONFIG::QUICKBOOKS[:consumer_key], OSB::CONFIG::QUICKBOOKS[:consumer_secret], oauth_params)
Quickbooks.sandbox_mode = true
