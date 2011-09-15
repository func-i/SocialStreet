SECRETS = YAML.load_file("#{::Rails.root.to_s}/config/secrets.yml")
TWITTER_APP_CONSUMER_KEY = SECRETS['twitter_app_consumer_key']
TWITTER_APP_CONSUMER_SECRET = SECRETS['twitter_app_consumer_secret']
FACEBOOK_APP_ID = SECRETS['facebook_app_id']
FACEBOOK_APP_SECRET = SECRETS['facebook_app_secret']

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, {
    :scope=>"publish_stream,email,offline_access",
    :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}    
  }
end
