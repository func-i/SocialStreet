class UserMailer < ActionMailer::Base
  default :from => ["SocialStreet", "notify@socialstreet.com"]

  layout "mail"

  if Rails.env.staging?
    default_url_options[:host] = "staging.socialstreet.com"
  elsif Rails.env.production?
    default_url_options[:host] = "socialstreet.com"
  else
    default_url_options[:host] = "localhost:3000"
  end

  # TODO: Maybe mention the subscription or link to subscription for unsubscribing ? 
  def event_creation_notice(user, event)
    @user = user
    @event = event
    mail(:to => user.email, :subject => "New StreetMeet of interest to you on SocialStreet")
  end

  # Top-level search /explore comments
  def search_comment_notice(user, comment)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => "New comment by #{comment.user.name} on SocialStreet")
  end

  # Non-top-level comment replies to an existing comment thread (on the search explore page, or otherwise)
  def action_comment_notice(user, comment)
    @user = user
    @comment = comment
    mail(:to => user.email, :subject => "New comment by #{comment.user.name} on SocialStreet")
  end

  def event_invitation_notice(invitation)
    @user = invitation.to_user
    @invitation = invitation
    @event = invitation.event
    mail(:to => @user.email, :subject => "#{invitation.user.name} invited you to '#{invitation.event.title}' on SocialStreet")
  end

  def daily_subscription_digest(subscription, actions, start_time, end_time)
    @actions = actions
    @subscription = subscription
    # time ranges used to determine which sub-actions to render, since @actions is always top-level actions
    @start_time = start_time
    @end_time = end_time
    mail(:to => @subscription.user.email, :subject => "Your daily summary for '#{subscription.name}' on SocialStreet")
  end

  def test_notice(user)
    @user = user
    mail(:to => user.email, :subject => "This is a test email")
  end

end
