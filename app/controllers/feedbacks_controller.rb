class FeedbacksController < ApplicationController

  def show
    @feedback = current_user.feedbacks.readonly(false).find params[:id]
    @event = @feedback.rsvp.event
    @rsvps = @event.rsvps.attending_or_maybe_attending.excluding_user(current_user).all
  end

  def update
    @feedback = current_user.feedbacks.readonly(false).find params[:id]
    
    @feedback.attributes = params[:feedback]
    @feedback.responded = true

    if @feedback.save
      if nil == @feedback.score
        #redirect_to :back, :notice => 'Thank you for your feedback.'
        redirect_to :back
      else
        Connection.connect_with_users_from_event(current_user, @feedback.rsvp.event)
        #redirect_to @feedback, :notice => 'Thank you for your feedback.'
        redirect_to @feedback
      end
    else
      #redirect_to :back, :notice => "Error: #{@feedback.errors.full_messages.first}"
      redirect_to :back
    end
  end

end
