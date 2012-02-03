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
    
    def time_to_next_hospital
      period = (hospital_used_at + hospital_delay) - Time.now
      
      period < 0 ? 0 : period.to_i
    end

    def hospital!
      if !hospital_enough_money?
        errors.add(:base, :hospital_not_enough_money)

        return false
      elsif hospital_recently_used?
        errors.add(:base, :hospital_recently_used)

        return false
      end

      charge(hospital_price, 0, :hospital)

      self.hp = health_points

      self.hospital_used_at = Time.now

      save
    end
    
    def hospital_recently_used?
      time_to_next_hospital > 0
    end
    
    def hospital_enough_money?
      basic_money > hospital_price
    end
    
    def hospital_may_heal?
      hospital_enough_money? && !hospital_recently_used?
    end
  end
end