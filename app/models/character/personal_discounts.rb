class Character
  module PersonalDiscounts
    def self.included(base)
      base.class_eval do
        has_many :personal_discounts,
          :extend     => PersonalDiscountAssociationExtension,
          :dependent  => :delete_all
      end
    end

    module PersonalDiscountAssociationExtension
      def current
        with_state(:active).not_expired.first
      end

      def generate_if_possible!
        if Setting.b(:personal_discount_enabled) and created_recently.count == 0
          generate!
        end
      end

      def generate!
        if item = Item.discountable_for(proxy_association.owner).first(:order => 'RAND()')
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