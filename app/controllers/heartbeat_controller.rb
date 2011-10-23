class HeartbeatController < ApplicationController

  #newrelic_ignore # Don't want this affecting apdex score on newrelic

  # /hb
  def index
    r = Redis.new
    r.keys 'abc' # just a random redis command
    c = User.count # random sql query
    r.quit
    render :text => "OK : #{Time.zone.now.to_s}"
  rescue Exception => e
    render :text => "ERROR : #{e.message}"
  end

  # /sim_error
  def error
    raise "simulated error to test exception handling"
  end

end
