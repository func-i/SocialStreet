class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  belongs_to :searchable, :dependent => :destroy # comments, actions, actions all store their searchable info in their Searchable record
  
  # The action(activity) for the event creation. NOTE: we could use :conditions to be more specific here,
  # incase there are more possible action records for a comment, such as deletion or editing
  has_one :action, :as => :reference

  after_create :make_searchable_explorable

  def nested?
    action && action.action # !nested == no parent action (action model is where the nesting / threading occurs)
  end

  def global?
    !commentable
  end

  protected

  def make_searchable_explorable
    searchable.update_attributes :explorable => true if searchable && global? && !nested?
  end
  
end
