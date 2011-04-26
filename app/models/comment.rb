class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  
  # The action(activity) for the event creation. NOTE: we could use :conditions to be more specific here,
  # incase there are more possible action records for a comment, such as deletion or editing
  has_one :action, :as => :reference 

  

end
