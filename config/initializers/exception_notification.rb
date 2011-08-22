SocialStreet::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[SocialStreet Error] ",
  :sender_address => %{"notifier" <notifier@socialstreet.com>},
  :exception_recipients => %w{jon.salis@railias.ca jborts@gmail.com}