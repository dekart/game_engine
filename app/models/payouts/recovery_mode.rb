module Payouts
  module RecoveryMode
    MODES = [:absolute, :percent]
    
    def recovery_mode
      @recovery_mode || :absolute
    end
    
    def recovery_mode=(value)
      @recovery_mode = value.to_sym
    end
    
    def recalc_value
      @recalc_value
    end
   
    def recalc_recovery(param_total)
      (recovery_mode == :absolute) ? @value : ((param_total / 100.0) * @value).ceil
    end
  end
end