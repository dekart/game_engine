module RestorableAttribute
  class Base
    def initialize(name, container, options = {})
      @name = name
      @container = container
      @options = options
    end

    def updated_at
      @container["#{@name}_updated_at"] || Time.now
    end

    def restore_rate
      if @options[:restore_rate].is_a?(Symbol)
        @container.send(@options[:restore_rate])
      else
        @options[:restore_rate] || 1
      end
    end

    def restore_period
      value = @options[:restore_period].is_a?(Symbol) ? @container.send(@options[:restore_period]) : @options[:restore_period]
      value ||= 5.minutes

      if restore_bonus
        value = (value * (100 - restore_bonus).to_f / 100).to_i
      end

      value
    end

    def restore_bonus
      @options[:restore_bonus].is_a?(Symbol) ? @container.send(@options[:restore_bonus]) : @options[:restore_bonus]
    end

    def limit
      @options[:limit] ? @container.send(@options[:limit]) : 1_000_000_000_000
    end

    def stored_value
      @container[@name]
    end

    def value
      calculated_value = self.stored_value + self.restore_rate * self.restores_since_last_update

      if calculated_value > self.limit
        return self.limit
      elsif calculated_value < 0
        return 0
      else
        return calculated_value
      end
    end

    def restores_since_last_update
      (Time.now - self.updated_at).to_i / self.restore_period
    end

    def value=(value)
      @container[@name] = value.to_i > 0 ? value : 0

      @container.send("#{@name}_updated_at=", 
        Time.now - (self.time_to_restore > 0 ? self.restore_period - self.time_to_restore : 0)
      )
    end

    def restore_time(restore_to)
      restore_to = self.limit if restore_to > self.limit

      if self.value >= restore_to
        return 0
      else
        (self.updated_at + ((restore_to - self.stored_value).to_f / self.restore_rate).ceil * self.restore_period - Time.now).to_i
      end
    end

    def time_to_restore
      return 0 if self.value == self.limit
      
      self.restore_period - (Time.now - self.updated_at).to_i % self.restore_period.to_i
    end
  end

  def restorable_attribute(name, options = {})
    define_method("#{name}_restorable") do
      @restorable_attributes ||= {}
      @restorable_attributes[name] ||= Base.new(name, self, options)
    end

    define_method("#{name}_updated_at") do
      send("#{name}_restorable").updated_at
    end

    define_method(name) do
      send("#{name}_restorable").value
    end

    define_method("#{name}=") do |value|
      send("#{name}_restorable").value = value
    end

    define_method("#{name}_restore_time") do |restore_to|
      send("#{name}_restorable").restore_time(restore_to)
    end

    define_method("time_to_#{name}_restore") do
      send("#{name}_restorable").time_to_restore
    end
  end
end