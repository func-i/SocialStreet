# Create the initial connections via facebook
class Jobs::CreateConnectionsFromFacebook

  @queue = :connections

  def self.perform(user_id)

    #sleep(50)

    timen = Time.now.to_f

    user = User.find(user_id)    
    fb = user.facebook_user
    friends = fb.friends

    # => unflag facebook friends that have unfriended other users
    uids_no_longer_friends = user.connections.where(:facebook_friend => true).collect(&:to_user).collect(&:fb_uid) - friends.collect(&:identifier)

    uids_no_longer_friends.each do |no_friend_id|
      no_user = User.find_by_fb_uid(no_friend_id)
      user.connections.to_user(no_user).each{|c| c.update_attribute("facebook_friend", false)}
    end

    user_inserts = []
    fb_user_ids = []
    while friends && !friends.empty?
      friends.each do |friend|
        #push identifier onto array
        fb_user_ids.push(friend.identifier)

        #Check if user exists
        if(User.where(:fb_uid => friend.identifier).count <= 0)
          first_name = (friend.first_name || friend.name.to_s.split.first).gsub(/[']/, '\'')
          last_name = (friend.first_name || friend.name.to_s.split.last).gsub(/['']/, '\'')
          user_inserts.push(
            "('#{friend.identifier}',
            '#{first_name}',
            '#{last_name}',
            '#{friend.picture}',
            '#{SearchSubscription.frequencies[:immediate]}')"
          )
        end
      end

      friends = friends.next
    end

    unless user_inserts.empty?
      sql = "INSERT INTO users (fb_uid, first_name, last_name, facebook_profile_picture_url, comment_notification_frequency) VALUES #{user_inserts.join(", ")}"
      User.connection.insert(sql)
    end

    ss_uids = User.select(:id).where(:fb_uid => fb_user_ids).all.collect(&:id)

    connection_inserts = []
    ss_uids.each do |uid|
      c = user.connections.to_user_id(uid).first
      if nil == c
        connection_inserts.push("('#{user.id}','#{uid}', 0, true)")
      else
        c.update_attribute("facebook_friend", true);
      end
    end

    unless connection_inserts.empty?
      sql = "INSERT INTO connections (user_id, to_user_id, strength, facebook_friend) VALUES #{connection_inserts.join(", ")}"
      Connection.connection.insert(sql)
      Connection.setAllRanks(user);
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