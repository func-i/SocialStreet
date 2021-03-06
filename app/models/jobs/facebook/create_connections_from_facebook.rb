# Create the initial connections via facebook
class Jobs::Facebook::CreateConnectionsFromFacebook

  @queue = :connections

  def self.perform(user_id)

    user = User.find(user_id)    
    fb = user.facebook_user
    friends = fb.friends

    user_inserts = []
    fb_user_ids = []
    while friends && !friends.empty?
      friends.each do |friend|
        #push identifier onto array
        fb_user_ids.push(friend.identifier)

        #Check if user exists
        if(User.where(:fb_uid => friend.identifier).count <= 0)
          first_name = (friend.first_name || friend.name.to_s.split.first).gsub(/[']/, "''")
          last_name = (friend.last_name || friend.name.to_s.split.last).gsub(/[']/, "''")
          user_inserts.push(
            "('#{friend.identifier}',
            '#{first_name}',
            '#{last_name}',
            '#{friend.picture}')"
          )
        end
      end

      friends = friends.next
    end

    unless user_inserts.empty?
      sql = "INSERT INTO users (fb_uid, first_name, last_name, facebook_profile_picture_url) VALUES #{user_inserts.join(", ")}"
      User.connection.insert(sql)
    end

    ss_uids = User.select(:id).where(:fb_uid => fb_user_ids).all.collect(&:id)

    connection_inserts = []
    ss_uids.each do |uid|
      c = user.connections.to_user_id(uid).first
      if nil == c
        connection_inserts.push("('#{user.id}','#{uid}', 5, true)")
      else
        c.update_attribute("facebook_friend", true);
      end
    end

    unless connection_inserts.empty?
      sql = "INSERT INTO connections (user_id, to_user_id, strength, facebook_friend) VALUES #{connection_inserts.join(", ")}"
      Connection.connection.insert(sql)

      Connection.set_all_ranks(user)
    end

    user.update_attribute("facebook_friends_imports", true)
  end

  def self.find_worker(user_id)
    return nil if !user_id
    
    Resque.workers.each do |worker|
      if !(job = worker.job).blank? && job["payload"]["class"].eql?(self.name) && job["payload"]["args"].eql?([user_id])
        return worker
      end
    end
    nil # => Explicitly return nil showing that no worker is running this job
  end

  def self.perform_sync_or_wait_for_async(user_id)
    
    # => Remove the job from the queue it is in there so we don't get duplicate connection creation jobs conflicting
    begin
      Resque.dequeue(Jobs::Facebook::CreateConnectionsFromFacebook, user_id)
    rescue Exception => e
      # => The queue probably could not be found
    end
    
    unless Jobs::Facebook::CreateConnectionsFromFacebook.find_worker(user_id).nil?
      while !Jobs::Facebook::CreateConnectionsFromFacebook.find_worker(user_id).nil?
        # => Do nothing, just keep checking for the completion of the worker
      end
    else
      # => Check one more time to see if it completed after the dequeue
      unless User.find(user_id).facebook_friends_imports?
        Jobs::Facebook::CreateConnectionsFromFacebook.perform(user_id)
      end
    end
  end
end