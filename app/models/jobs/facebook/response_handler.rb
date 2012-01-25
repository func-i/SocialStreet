# Create the initial connections via facebook
class Jobs::Facebook::ResponseHandler

  @queue = :connections

  def self.perform(params)
    case params["object"]
    when "user"
      # => Right now everything will be a user, but set it up so it can be something else.
      if params.has_key?("entry")
        for entry in params["entry"]          
          user = User.find_by_fb_uid entry["uid"]          
          if user
            Resque.enqueue(Jobs::Facebook::CreateConnectionsFromFacebook, user.id) if entry["changed_fields"].include?("friends")
          end
        end
      end
    end
  end
end