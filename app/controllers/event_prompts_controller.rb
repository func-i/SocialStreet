class EventPromptsController < ApplicationController

  before_filter :ss_authenticate_user!
  before_filter :authenticate_god
  before_filter :load_event

  def new
    if @event.event_prompts.blank?
      (1..3).to_a.each do |i|
        @event.event_prompts.build(:sequence => i)
      end
    end
  end

  def create
    if @event.update_attributes(params[:event])
      redirect_to @event
    else
      render :new
    end
  end


  protected

  def authenticate_god
    raise ActiveRecord::RecordNotFound unless current_user.god?
  end

  def load_event
    @event = Event.find params[:event_id]
  end

end