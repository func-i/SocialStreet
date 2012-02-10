class AddSmowAnswerToEventRsvps < ActiveRecord::Migration
  def change

    add_column :events, :prompt_question, :string
    add_column :event_rsvps, :prompt_answer, :string

  end
end
