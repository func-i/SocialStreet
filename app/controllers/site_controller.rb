class SiteController < ApplicationController

  def hb
    r = Redis.new
    r.keys 'abc' # just a random redis command
    c = User.count # random sql query
    r.quit
    render :text => "OK"
  rescue Exception => e
    render :text => e.message
  end
  
  def index
    # home page
  end

  def how
    
  end

end
