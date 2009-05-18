module RestorableAttribute
  def restorable_attribute(name, limit, restore_period)
    define_method("#{name}_updated_at") do
      self["#{name}_updated_at"] || Time.now
    end

    define_method(name) do
      calculated_value = self[name] + (Time.now - self.send("#{name}_updated_at")).to_i / restore_period

      if calculated_value > self.send(limit)
        return self.send(limit)
      elsif calculated_value < 0
        return 0
      else
        return calculated_value
      end
    end

    define_method("#{name}=") do |value|
      compensation = restore_period - self.send("time_to_#{name}_restore")
      self[name] = value
      self.send("#{name}_updated_at=", Time.now - compensation)
    end

    define_method("#{name}_restore_time") do |restore_to|
      restore_to = self.send(limit) if restore_to > self.send(limit)

      if self.send(name) >= restore_to
        return 0
      else
        (self.send("#{name}_updated_at") + (restore_to - self[name]) * restore_period - Time.now).to_i
      end
    end

    define_method("time_to_#{name}_restore") do
      send("#{name}_restore_time", self.send(name) + 1)
    end
  end
end