# migrate data in app_request to target
class ChangeAppRequestsDataToTarget < ActiveRecord::Migration
  def self.up
    AppRequest::Base.transaction do
      AppRequest::Base.find_each(:conditions => ["data is not null"]) do |app_request|
        data = app_request.data
        
        if (target_id = data['monster_id'] || data['item_id'])
          
          target_type, target_id = data.select {|k, v| ['monster_id', 'item_id'].include?(k) }.first
          
          target_class = target_type.gsub(/_id/, '').classify.constantize
          data.delete(target_type)
          
          data['target_id'] = target_id
          data['target_type'] = target_class.name
          
          app_request.target = target_class.find(target_id)
          
          app_request.save!
        end
      end
    end
  end

  def self.down
  end
end
