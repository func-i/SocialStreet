# Create the initial connections via facebook
class Jobs::CleanupDashboardSet
  @queue = :connections

  def self.perform(action_id)
  end
end