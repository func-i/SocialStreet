class CreateEventPrompts < ActiveRecord::Migration
  def up
    create_table :event_prompts do |t|
      t.integer :event_id
      t.text :prompt_question
      t.integer :sequence
      t.string :answer_type
      t.timestamps
    end

  end

  def down
  end
end
