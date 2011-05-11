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
      redirect_to @feedback, :notice => 'Thank you for your feedback.'
    else
      redirect_to :back, :notice => "Error: #{@feedback.errors.full_messages.first}"
    end
  end

end
