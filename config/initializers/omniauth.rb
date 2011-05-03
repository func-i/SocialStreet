if Rails.env.development?
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end

# Since we don't care to use the secrets.yml on production which is Heroku, we hard code those values here
if Rails.env == 'production'
  TWITTER_APP_CONSUMER_KEY = 'Uqgqk2dtnjMNgIIV7QXfnA'
  TWITTER_APP_CONSUMER_SECRET = 'xXKPdgUPjowXE2UlsbGdzD7qA7sUOvPyG26jEFavvY'
  FACEBOOK_APP_ID = '193957000641042'
  FACEBOOK_APP_SECRET = 'd804dbfa6a2dc1db31ecd30536099ab0'
else
  # each developer can have their own test applications in twitter / facebook / etc by editing the secrets.yml
  SECRETS = YAML.load_file("#{::Rails.root.to_s}/config/secrets.yml")
  TWITTER_APP_CONSUMER_KEY = SECRETS['twitter_app_consumer_key']
  TWITTER_APP_CONSUMER_SECRET = SECRETS['twitter_app_consumer_secret']
  FACEBOOK_APP_ID = SECRETS['facebook_app_id']
  FACEBOOK_APP_SECRET = SECRETS['facebook_app_secret']
end
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_APP_CONSUMER_KEY, TWITTER_APP_CONSUMER_SECRET
  provider :facebook, FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, {:client_options => {:ssl => {:ca_path => Rails.env.development? ? "/opt/local/etc/openssl" : "/etc/ssl/certs"}}}
  #  provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
