class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  before_save Proc.new{|comment| comment.body = comment.body.gsub("\r", "<br />")}
 
end
