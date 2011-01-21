class Character
  module Hospital
    def hospital_price
      Setting.i(:hospital_price) +
        (Setting.f(:hospital_price_per_point_per_level) * level * (health_points - hp)).round
    end

    def hospital_delay
      value =
        Setting.i(:hospital_delay) +
        Setting.i(:hospital_delay_per_level) * level

      value.minutes
    end

    def hospital!
      if basic_money < hospital_price
        errors.add_to_base(:hospital_not_enough_money)

        return false
      elsif hospital_used_at > hospital_delay.ago
        errors.add_to_base(:hospital_recently_used)

        return false
      end

      charge(hospital_price, 0, :hospital)

      self.hp = health_points

      self.hospital_used_at = Time.now

      save
    end
  end
end