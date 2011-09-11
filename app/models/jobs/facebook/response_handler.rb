class Jobs::Facebook::ResponseHandler

  @queue = :connections

  def self.perform(params)

    # => Example FB response {"object"=>"user", "entry"=>[{"uid"=>"100002434764514", "id"=>"100002434764514", "time"=>1308022101, "changed_fields"=>["friends"]}, {"uid"=>"100002538606649", "id"=>"100002538606649", "time"=>1308022101, "changed_fields"=>["friends"]}]}    

    case params["object"]
    when "user"
      # => Right now everything will be a user, but set it up so it can be something else.
      if params.has_key?("entry")
        for entry in params["entry"]          
          user = User.find_by_fb_uid entry["uid"]          
          if user
            if entry["changed_fields"].include?("friends")
              fb = user.facebook_user
              friends = fb.friends              

              user_fb_friends_uids = user.connections.where(:facebook_friend => true).collect(&:to_user).collect(&:fb_uid)
              
              # => unflag facebook friends that have unfriended other users
              uids_no_longer_friends = user_fb_friends_uids - friends.collect(&:identifier)

              uids_no_longer_friends.each do |no_friend_id|
                no_user = User.find_by_fb_uid(no_friend_id)
                user.connections.to_user(no_user).each{|c| c.update_attribute("facebook_friend", false)}
              end

              new_friends = friends.select{|f| !user_fb_friends_uids.include?(f.identifier)}

              user_inserts = []
              user_values = []
              
              new_friends.each do |newf|

                next if User.where(:fb_uid => newf.identifier).count > 0
                first_name = (newf.first_name || newf.name.to_s.split.first).gsub(/[']/, "''")
                last_name = (newf.last_name || newf.name.to_s.split.last).gsub(/[']/, "''")

                user_inserts << "(" + Array.new(5, "?").join(",") + ")"

                user_values += [
                  newf.identifier,
                  first_name,
                  last_name,
                  newf.picture,
                  SearchSubscription.frequencies[:immediate]]              
              end

              unless user_inserts.empty?
                sql = "INSERT INTO users (fb_uid, first_name, last_name, facebook_profile_picture_url, comment_notification_frequency) VALUES #{user_inserts.join(", ")}"
                User.execute_sql([sql] + user_values)
              end

              ss_uids = User.select(:id).where(:fb_uid =>new_friends.collect(&:identifier)).all.collect(&:id)

              connection_inserts = []
              connection_values = []
              c_fb_friends = []
              
              ss_uids.each do |uid|
                c = user.connections.to_user_id(uid).first
                if nil == c
                  connection_inserts << "(" + Array.new(4, "?").join(",") + ")"
                  connection_values += [user.id, uid, 5, true]
                else
                  c_fb_friends << c.id unless c.facebook_friend?
                end
              end

              Connection.update_all({:facebook_friend => true}, {:id => c_fb_friends}) unless c_fb_friends.empty? 

              unless connection_inserts.empty?
                sql = "INSERT INTO connections (user_id, to_user_id, strength, facebook_friend) VALUES #{connection_inserts.join(", ")}"
                User.execute_sql([sql] + connection_values)
                Connection.set_all_ranks(user)
              end

            end
          end
          
        end
      end
    end
  end
  
end