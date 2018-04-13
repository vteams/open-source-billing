#Developemnt
OAUTH_CONSUMER_KEY = "Q0pXk97gDUL216bKrXxkpvwtQRcHiziESQnX2UPa8DPYEgqVWT"   #new sandbox a/c for tabish.saleem@nxb.com
OAUTH_CONSUMER_SECRET = "mN2DSkq4HZeq3CnmzmtE1veDRfj3HhhYCOJXWTno"          #new sandbox a/c for tabish.saleem@nxb.com

#Production
# OAUTH_CONSUMER_KEY = "Q0MKd1gPqFPsQuNK4BqqLzUtnJAeNqggYzHOO0avNaoVsxHXu6"    #new LIVE APP a/c for tabish.saleem@nxb.com
# OAUTH_CONSUMER_SECRET = "FUO3GbohDyti4Ec9CP22TftwJNSDI56TZCgQrSO8"           #new LIVE APP a/c for tabish.saleem@nxb.com

oauth_params = {
    :site => "https://appcenter.intuit.com/connect/oauth2",
    :authorize_url => "https://appcenter.intuit.com/connect/oauth2",
    :token_url => "https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer"
}

::QB_OAUTH2_CONSUMER = OAuth2::Client.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, oauth_params)
Quickbooks.sandbox_mode = true


oauth_params = {
    site: 'https://appcenter.intuit.com/connect/oauth2',
    authorize_url: 'https://appcenter.intuit.com/connect/oauth2',
    token_url: 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer'
}
APP_CONFIG = HashWithIndifferentAccess.new(YAML.load_file(Rails.root.join('config','config.yml'))[Rails.env])
::QB_OAUTH2_CONSUMER = OAuth2::Client.new(APP_CONFIG[:OAUTH_CONSUMER_KEY], APP_CONFIG[:OAUTH_CONSUMER_SECRET], oauth_params)
Quickbooks.sandbox_mode = true