class Connection < ActiveRecord::Base
  belongs_to :user
  belongs_to :to_user, :class_name => "User"

  scope :to_user, lambda { |user| where(:to_user_id => user.id) }
  scope :to_user_id, lambda { |user_id| where(:to_user_id => user_id) }

  scope :to_user_matches_keyword, lambda{ |keyword|
    where("users.last_name ~* ? OR users.first_name ~* ?", keyword, keyword)
  }

  def self.set_all_ranks(user)
    Connection.connection.update("UPDATE connections co
          SET rank = ranked_tbl.newRank
          FROM (
            SELECT c.id, rank() OVER (PARTITION BY c.user_id ORDER BY strength DESC) newRank
            FROM connections c
            WHERE c.user_id = #{user.id}
          ) as ranked_tbl
          WHERE co.id = ranked_tbl.id")
  end
end
