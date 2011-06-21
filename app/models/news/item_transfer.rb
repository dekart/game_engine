module News
  class ItemTransfer < Base
    def sender
      @sender ||= Character.find(data[:sender_id])
    end
    
    def items
      @items ||= Item.find(data[:items].collect{|v| v.first }).collect{|item| 
        [item, data[:items].assoc(item.id).last] 
      }
    end
  end
end
