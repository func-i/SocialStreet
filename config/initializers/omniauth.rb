# Since we don't care to use the secrets.yml on production which is Heroku, we hard code those values here
if Rails.env == 'production'
  TWITTER_APP_CONSUMER_KEY = ''
  TWITTER_APP_CONSUMER_SECRET = ''
else
  # each developer can have their own test applications in twitter / facebook / etc by editting the secrets.yml
  SECRETS = YAML.load_file("#{::Rails.root.to_s}/config/secrets.yml")
  TWITTER_APP_CONSUMER_KEY = SECRETS['twitter_app_consumer_key']
  TWITTER_APP_CONSUMER_SECRET = SECRETS['twitter_app_consumer_secret']
end
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, TWITTER_APP_CONSUMER_KEY, TWITTER_APP_CONSUMER_SECRET
  #  provider :facebook, 'APP_ID', 'APP_SECRET'
  #  provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end
