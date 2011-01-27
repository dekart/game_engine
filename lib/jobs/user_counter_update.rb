module Jobs
  class UserCounterUpdate < Struct.new(:user_ids)
    def perform
      user_ids.each do |id|
        user = User.find_by_id(id)
        
        user.update_dashboard_counters!
      end
    end
  end
end