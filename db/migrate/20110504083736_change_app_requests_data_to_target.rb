# migrate data in app_request to target
class ChangeAppRequestsDataToTarget < ActiveRecord::Migration
  def self.up
    AppRequest::Base.transaction do
      AppRequest::Base.find_each(:conditions => ["data is not null and target_id is null"]) do |app_request|
        if app_request.data['monster_id']
          app_request.target = Monster.find(app_request.data['monster_id'])
          app_request.save!
        elsif app_request.data['item_id']
          app_request.target = Item.find(app_request.data['item_id'])
          app_request.save!
        end
      end
    end
  end

  def self.down
  end
end
