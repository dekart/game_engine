class Character
  class Equipment  
    module Inventories
      class Inventory
        attr_accessor :item_id, :amount, :equipped
        
        delegate(
          *(
            %w{
              item_group name plural_name description pictures pictures?
              basic_price vip_price can_be_sold? can_be_sold_on_market? sell_price exchangeable?
              placements placement_options_for_select
              payouts payouts? usable? use_button_label use_message effects effects? effect boost?
              boost_type
            } +
            [{:to => :item}]
          )
        )
        
        def initialize(options)
          self.item_id  = options[:item_id]
          self.amount   = options[:amount] || 1
          self.equipped = options[:equipped] || 0
              
          self
        end
  
        def item
          @item ||= Item.find_by_id(item_id)
        end
        
        def amount_available_for_equipment
          amount - equipped
        end
        
        def equippable?
          item.equippable? and amount_available_for_equipment > 0
        end
       
        def equipped?
          equipped > 0
        end
        
        def usable?
          item.usable? && amount > 0
        end
        
        def use!(character)
          return false unless usable?
      
          Character::Equipment.transaction do
            payouts.apply(character, :use, item).tap do
              character.inventories.take!(item)
              
              self.amount = character.inventories.count(item)
              
              character.save
            end
          end
        end
        
        def to_attr_hash
          {:item_id => item_id, :amount => amount, :equipped => equipped }
        end
        
        def to_s
          "#<Inventory: @item_id=#{item_id}, @amount=#{amount}, @equipped=#{equipped}>"
        end
      end
    end
  end
end
