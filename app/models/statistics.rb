class Statistics
  def initialize(time_range = nil, scope = nil)
    if time_range.is_a?(Range)
      @time_range = time_range
    elsif time_range.present?
      @time_range = (time_range .. Time.now)
    end
    
    self.scope = scope
  end
  
  def numeric_time_range
    Range.new(@time_range.begin.to_i, @time_range.end.to_i)
  end
  
  def scoped(scope)
    self.class.new(@time_range, self.scope.scoped(scope))
  end

  def scope=(value)
    if value.class == ActiveRecord::Scoping::Named
      @scope = value
    else
      @scope = default_scope.scoped(value)
    end
  end
  
  def scope
    @scope || default_scope
  end
end
