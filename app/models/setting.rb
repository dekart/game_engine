class Setting < ActiveRecord::Base
  validates_presence_of   :alias
  validates_uniqueness_of :alias

  class << self
    def cache
      return {} unless table_exists?

      $memory_store.fetch('settings', :expires_in => 1.minute) do
        {}.tap do |result|
          all.each do |setting|
            result[setting.alias.to_sym] = setting.value
          end
        end
      end
    end

    # Returns value casted to integer
    def i(key)
      cache[key.to_sym].to_i
    end

    # Returns value casted to string
    def s(key)
      cache[key.to_sym].to_s
    end

    # Returns value casted to float
    def f(key)
      cache[key.to_sym].to_f
    end

    # Returns value casted to boolean
    def b(key)
      value = cache[key.to_sym].to_s.downcase

      %w{true yes 1}.include?(value) ? true : false
    end

    # Returns value casted to string array (splits string value by comma)
    def a(key)
      cache[key.to_sym].to_s.split(/\s*,\s*/)
    end

    # Returns percentage value casted to float
    def p(key, value_to_cast)
      value_to_cast * cache[key.to_sym].to_i * 0.01
    end

    def time(key)
      if value = cache[key.to_sym]
        ActiveSupport::TimeZone["UTC"].parse(value)
      else
        ActiveSupport::TimeZone["UTC"].at(0)
      end
    end

    def []=(key, value)
      if value.is_a?(Time)
        value = value.utc
      end

      if value.nil?
        find_by_alias(key.to_s).try(:destroy)
      elsif existing = find_by_alias(key.to_s)
        existing.update_attributes(:value => value)
      else
        create(:alias => key.to_s, :value => value)
      end

      $memory_store.delete('settings')
    end

    def [](key)
      find_by_alias(key.to_s).try(:value)
    end
  end
end
