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

  #Sent when the user first logs in
  def user_welcome_notice(user)
    @user = user
    mail(:to => @user.email, :subject => "Welcome to SocialStreet") unless @user.email.blank?
  end

  #Sent when an event is canceled
  def event_cancel_notice(user, event)
    @user = user
    @event = event
    mail(:to => @user.email, :subject => "StreetMeet - #{event.title}' has been cancelled") unless @user.email.blank?
  end

  #Sent when an event details are changed...TODO - should only be important details
  def event_edit_notice(user, event)
    @user = user
    @event = event
    mail(:to => @user.email, :subject => "StreetMeet - #{event.title}' has been edited") unless @user.email.blank?
  end

  #Send when a user is invited to an event
  def event_invitation_notice(invitation)
    @user = invitation.user
    @invitation = invitation
    @event = invitation.event
    email = invitation.email || @user.try(:email)
    mail(:to => email, :subject => "#{invitation.invitor.name} invited you to '#{invitation.event.title}' on SocialStreet") unless email.blank?
  end

  #Send when a new comment thread is created in an event
  def event_admin_message_notice(action, user, event)
    @action = action
    @user = user
    @event = event
    
    mail(:to => @user.email, :subject => "#{@action.user.name} posted on your StreetMeet - #{event.title}") unless @user.email.blank?
  end

  #Send when a new action is posted to a thread the user already participated in
  def action_chain_notice(head_action, user, new_action)
    @head_action = head_action
    @user = user
    @new_action = new_action

    mail(:to => @user.email, :subject => "#{new_action.user.name} replied to your SocialStreet Message") unless @user.email.blank?
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

    mail(:to => @user.email, :subject => subject) unless @user.email.blank?
  end

  #Send when a new action matches a users summary suscription and the cron task is run (daily/weekly)
  def subscription_summary_notice(subscription, actions, user)
    @actions = actions
    @subscription = subscription
    @user = user

    return nil if @subscription.user.email.blank?
    mail(:to => @subscription.user.email, :subject => "SocialStreet #{@subscription.frequency == SearchSubscription.frequencies[:daily] ? 'Daily' : 'Weekly'} Summary - #{subscription.name}") 
  end

  def send_feedback_mail(email, request)
    @name = email[:name]
    @the_body = email[:body]
    @request = request
    mail(:to => "jborts@socialstreet.com", :subject => "User feedback")
  end

  def test_notice(user)
    @user = user
    return nil if user.email.blank?
    mail(:to => user.email, :subject => "This is a test email")
  end

  def streetmeet_of_the_week(smow, email)
    return nil if email.blank?
    mail(:to => email, :subject => "StreetMeet of the Week - FREE #{smow.title}") do |format|
      format.html {render :file => "/smows/_smow.html.erb", :locals => {:event => smow.event, :smow => smow}, :layout => false}
    end
  end

  #Send when a new comment thread is created in an event
  def event_admin_message_notice(comment, organizer, event)
    @comment = comment
    @organizer = organizer
    @event = event

    return nil if organizer.email.blank?
    mail(:to => @organizer.email, :subject => "#{@comment.user.name} posted on your StreetMeet - #{event.title}")
  end

  # => Send a message from the organizer to the attendee
  def event_admin_message_to_attendee(event, attendee, message)
    @event = event
    @attendee = attendee
    @message = message

    return nil if attendee.user.email.blank?
    mail(:to => attendee.user.email, :subject => "A new message from the organizer - #{event.title}")
  end

  def streetmeet_of_the_week_summary(body)
    mail(:to => ["jon.salis@railias.ca", "jborts@gmail.com", "paul@socialstreet.com"], :subject => "Streetmeet #{Date.today.to_s} Stats") do |format|
      format.html {render :text => body}
    end
  end

end
