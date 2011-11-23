module Payouts
  module RecoveryMode
    MODES = [:absolute, :percent]
    
    def recovery_mode
      @recovery_mode || :absolute
    end
    
    def recovery_mode=(value)
      @recovery_mode = value.to_sym
    end
  end
end