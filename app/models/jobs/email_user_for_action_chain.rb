class Jobs::EmailUserForActionChain

  @queue = :emails

  # the "orig_action_id" is the action that was in the same chain as the new action represented by "action_id"
  def self.perform(head_action_id, new_action_id, user_id)
    head_action = Action.find head_action_id
    new_action = Action.find new_action_id
    user = User.find user_id

    email = UserMailer.action_chain_notice(head_action, user, new_action)

    email.deliver if email
  end
end