module Payouts
  module RecoveryMode
    MODES = [:absolute, :percent]
    
    def recovery_mode
      @recovery_mode || :absolute
    end
    
    def recovery_mode=(value)
      @recovery_mode = value.to_sym
    end
    
    def calculated_value
      @calculated_value
    end
   
    def calculate_value(total)
      (recovery_mode == :absolute) ? @value : ((total / 100.0) * @value).ceil
    end
  end
end