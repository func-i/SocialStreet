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
            Resque.enqueue(Jobs::CreateConnectionsFromFacebook, user.id) if entry["changed_fields"].include?("friends")
          end
        end
      end
    end    
  end
  
end