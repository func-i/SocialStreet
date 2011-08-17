# Create the initial connections via facebook
class Jobs::CreateConnectionsFromFacebook

  @queue = :connections

  def self.perform(user_id)
    user = User.find(user_id)
    
    fb = user.facebook_user
    friends = fb.friends

    # => unflag facebook friends that have unfriended other users
    uids_no_longer_friends = user.connections.where(:facebook_friend => true).collect(&:to_user).collect(&:fb_uid) - friends.collect(&:identifier)

    uids_no_longer_friends.each do |no_friend_id|
      no_user = User.find_by_fb_uid(no_friend_id)
      user.connections.to_user(no_user).each{|c| c.update_attribute("facebook_friend", false)}
    end

    # => Not sure why there is a while loop here when only the users friends are creating connections
    # => user.facebook_user.friends.next seems to always eql? [] which means this will only loop through once.
    while friends && !friends.empty?
      friends.each do |friend|
        u = User.find_by_fb_uid(friend.identifier)
        u ||= User.create({
            :fb_uid => friend.identifier,
            :first_name => friend.first_name || friend.name.to_s.split.first,
            :last_name => friend.last_name || friend.name.to_s.split.last,
            :facebook_profile_picture_url => friend.picture
          })

        c = user.connections.to_user(u).first
        c ||= user.connections.create({:to_user => u})

        c.update_attribute("facebook_friend", true)

      end

      friends = friends.next

    end

    user.update_attribute("fb_friends_imported", true)
    
  end

  def self.find_worker(user_id)
    Resque.workers.each do |worker|
      if !worker.job.empty? && worker.job["payload"]["class"].eql?(self.name) && worker.job["payload"]["args"].eql?([user_id])
        return worker
      end
    end
    nil # => Explicitly return nil showing that no worker is running this job
  end

  def self.perform_sync_or_wait_for_async(user_id)
    
    # => Remove the job from the queue it is in there so we don't get duplicate connection creation jobs conflicting
    begin
      Resque.dequeue(Jobs::CreateConnectionsFromFacebook, user_id)
    rescue Exception => e
      # => The queue probably could not be found
    end
    
    unless Jobs::CreateConnectionsFromFacebook.find_worker(user_id).nil?
      while !Jobs::CreateConnectionsFromFacebook.find_worker(user_id).nil?
        # => Do nothing, just keep checking for the completion of the worker
      end
    else
      # => Check one more time to see if it completed after the dequeue
      unless User.find(user_id).fb_friends_imported?
        Jobs::CreateConnectionsFromFacebook.perform(user_id)
      end      
    end
  end

end