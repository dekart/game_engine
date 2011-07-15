class Character
  module PersonalDiscounts
    def self.included(base)
      base.class_eval do
        has_many :personal_discounts, :extend => PersonalDiscountAssociationExtension
      end
    end
    
    module PersonalDiscountAssociationExtension
      def current
        with_state(:active).not_expired.first
      end
      
      def generate_if_possible!
        if Setting.b(:personal_discount_enabled) and count(:conditions => ["available_till > ?", Setting.i(:personal_discount_period).hours.ago.utc]) == 0
          generate!
        end
      end
      
      def generate!
        if item = Item.discountable_for(proxy_owner).first(:order => 'RAND()')
          discount = rand(Setting.i(:personal_discount_maximum_discount) - Setting.i(:personal_discount_minimum_discount)) + 
            Setting.i(:personal_discount_minimum_discount)
        
          create!(
            :item           => item, 
            :price          => (item.vip_price * (1 - 0.01 * discount)).floor,
            :available_till => Setting.i(:personal_discount_time_frame).minutes.from_now
          )
        end
      end
    end
  end
end