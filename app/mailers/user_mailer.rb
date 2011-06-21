class UserMailer < ActionMailer::Base
  default :from => "no-reply@socialstreet.com"
  layout "mail"

  if Rails.env.staging?
    default_url_options[:host] = "staging.socialstreet.com"
  elsif Rails.env.production?
    default_url_options[:host] = "socialstreet.com"
  else
    default_url_options[:host] = "localhost:3000"
  end

  # TODO: Maybe mention the subscription or link to subscription for unsubscribing ? 
  def event_creation_notice(user, event, subscription)
    @user = user
    @event = event
    mail(:to => user.email, :subject => "A new activity of interest on SocialStreet")
  end

  def test_notice(user)
    @user = user
    mail(:to => user.email, :subject => "This is a test email")
  end

end
