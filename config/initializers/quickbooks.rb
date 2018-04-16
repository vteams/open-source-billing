oauth_params = {
                site: 'https://appcenter.intuit.com/connect/oauth2',
                authorize_url: 'https://appcenter.intuit.com/connect/oauth2',
                token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
               }
::QB_OAUTH2_CONSUMER = OAuth2::Client.new(OSB::CONFIG::OAUTH_CONSUMER_KEY, OSB::CONFIG::OAUTH_CONSUMER_SECRET, oauth_params)
Quickbooks.sandbox_mode = true
