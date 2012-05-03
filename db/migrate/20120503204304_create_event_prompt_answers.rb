class CreateEventPromptAnswers < ActiveRecord::Migration
  def change
    create_table :event_prompt_answers do |t|
      t.text :value
      t.references :event_prompt
      t.references :event_rsvp
      t.timestamps
    end
  end
end
