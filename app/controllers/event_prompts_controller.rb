class EventPromptsController < ApplicationController

  before_filter :ss_authenticate_user!, :except => :load_prompt_content
  before_filter :load_event, :except => :load_prompt_content

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

  def load_prompt_content
    @event = Event.find params[:event_id]
    render :partial => 'shared/prompt_content', :locals => {:event => @event}
  end

  protected

  def load_event
    @event = Event.find params[:event_id]
    raise ActiveRecord::RecordNotFound unless @event.can_view?(current_user)
  end

end