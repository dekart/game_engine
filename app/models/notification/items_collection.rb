module Notification
  class ItemsCollection < Base
    def collection
      @collection ||= ItemCollection.find(data[:collection_id])
    end   
  end
end