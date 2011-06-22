class Jobs::EmailUserForActionChain

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(action_id, orig_action_id)
    action = Action.find action_id
    orig_action = Action.find orig_action_id
    user = orig_action.user # user to notify

    if action.action_type == Action.types[:event_created]
      event = action.event
      email = UserMailer.event_creation_notice(user, event)
    elsif action.action_type == Action.types[:search_comment]
      comment = action.reference
      email = UserMailer.search_comment_notice(user, comment)
    elsif action.action_type == Action.types[:action_comment]
      comment = action.reference
      email = UserMailer.action_comment_notice(user, comment)
    end
    
    email.deliver if email
    
  end
end