class UserMailer < ActionMailer::Base
  default :from => "\"SocialStreet\" <notify@socialstreet.com>"

  helper :application

  layout "mail"

  if Rails.env.staging?
    default_url_options[:host] = "staging.socialstreet.com"
  elsif Rails.env.production?
    default_url_options[:host] = "socialstreet.com"
  else
    default_url_options[:host] = "localhost:3000"
  end

  #  # TODO: Maybe mention the subscription or link to subscription for unsubscribing ?
  #  def event_creation_notice(user, event)
  #    @user = user
  #    @event = event
  #    mail(:to => user.email, :subject => "New StreetMeet of interest to you on SocialStreet")
  #  end
  #
  #  # Top-level search /explore comments
  #  def search_comment_notice(user, comment)
  #    @user = user
  #    @comment = comment
  #    mail(:to => user.email, :subject => "New comment by #{comment.user.name} on SocialStreet")
  #  end
  #
  #  # Non-top-level comment replies to an existing comment thread (on the search explore page, or otherwise)
  #  def action_comment_notice(user, comment)
  #    @user = user
  #    @comment = comment
  #    mail(:to => user.email, :subject => "New comment by #{comment.user.name} on SocialStreet")
  #  end

  #Sent when the user first logs in
  def user_welcome_notice(user)
    @user = user
    mail(:to => @user.email, :subject => "Welcome to SocialStreet")
  end

  #Sent when an event is canceled
  def event_cancel_notice(user, event)
    @user = user
    @event = event
    mail(:to => @user.email, :subject => "StreetMeet - #{event.title}' has been cancelled")
  end

  #Sent when an event details are changed...TODO - should only be important details
  def event_edit_notice(user, event)
    @user = user
    @event = event
    mail(:to => @user.email, :subject => "StreetMeet - #{event.title}' has been edited")
  end

  #Send when a user is invited to an event
  def event_invitation_notice(invitation)
    @user = invitation.to_user
    @invitation = invitation
    @event = invitation.event
    mail(:to => @user.email, :subject => "#{invitation.user.name} invited you to '#{invitation.event.title}' on SocialStreet")
  end

  #Send when a new action is posted to a thread the user already participated in
  def action_chain_notice(head_action, user, new_action)
    @head_action = head_action
    @user = user
    @new_action = new_action

    mail(:to => @user.email, :subject => "#{new_action.user.name} replied to your SocialStreet Message")
  end

  #Send when a new action matches a users instant subscription
  def subscription_instant_notice(subscription, action, user)
    @subscription = subscription
    @action = action
    @user = user

    if action.action_type == Action.types[:event_created]
      subject = "StreetMeet - #{subscription.name}"
    elsif action.action_type == Action.types[:search_comment]
      subject = "SocialStreet Message - #{subscription.name}"
    elsif action.action_type == Action.types[:action_comment]
      subject = "SocialStreet Message - #{subscription.name}"
    end

    mail(:to => @user.email, :subject => subject)
  end

  #Send when a new action matches a users summary suscription and the cron task is run (daily/weekly)
  def subscription_summary_notice(subscription, actions, user)
    @actions = actions
    @subscription = subscription
    @user = user
    
    mail(:to => @subscription.user.email, :subject => "SocialStreet #{@subscription.frequency == SearchSubscription.frequencies[:daily] ? 'Daily' : 'Weekly'} Summary - #{subscription.name}")
  end

  def test_notice(user)
    @user = user
    mail(:to => user.email, :subject => "This is a test email")
  end

end
