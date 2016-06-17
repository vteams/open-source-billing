OAUTH_CONSUMER_KEY = "qyprdzo7cVme1O5Vtd8HBYoQ6IUoLQ"
OAUTH_CONSUMER_SECRET = "6gCs1FaLU0TIQGuNVKgUbOdQqPKq058B7IJbHQ6J"

::QB_OAUTH_CONSUMER = OAuth::Consumer.new(OAUTH_CONSUMER_KEY, OAUTH_CONSUMER_SECRET, {
                                                                :site                 => "https://oauth.intuit.com",
                                                                :request_token_path   => "/oauth/v1/get_request_token",
                                                                :authorize_url        => "https://appcenter.intuit.com/Connect/Begin",
                                                                :access_token_path    => "/oauth/v1/get_access_token"
                                                            })
Quickbooks.sandbox_mode = true