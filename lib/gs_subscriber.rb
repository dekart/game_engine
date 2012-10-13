module GsSubscriber
  class << self
    def mission_success(options = {})
      GS.log(:mission_success, options[:mission].name,
        :energy       => - options[:energy],
        :basic_money  => options[:basic_money],
        :experience   => options[:experience],
      )
    end

    def buy_item(options = {})
      GS.log(:buy_item, options[:item].name,
        :basic_money => - options[:basic_money],
        :vip_money   => - options[:vip_money]
      )
    end

    def sell_item(options = {})
      GS.log(:sell_item, options[:item].name, :basic_money => options[:basic_money])
    end

    def monster_attack(options = {})
      GS.log(:monster_attack, options[:monster].name,
        :stamina      => - options[:stamina],
        :basic_money  => options[:basic_money],
        :experience   => options[:experience],
      )
    end
  end
end