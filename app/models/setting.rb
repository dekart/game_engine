class Setting < ActiveRecord::Base
  validates_presence_of   :alias
  validates_uniqueness_of :alias

  after_save :restart_server
  after_destroy :restart_server
  
  cattr_accessor :cache

  class << self
    def cache_values!(force = false)
      if cache.nil? || force
        self.cache = all.inject({}){|result, s|
          result[s.alias.to_sym] = s.value
          result
        }
      end
      
      cache
    end

    # Returns value casted to integer
    def i(key)
      cache_values!

      cache[key.to_sym].to_i
    end

    # Returns value casted to string
    def s(key)
      cache_values!

      cache[key.to_sym].to_s
    end

    # Returns value casted to float
    def f(key)
      cache_values!

      cache[key.to_sym].to_f
    end

    # Returns value casted to boolean
    def b(key)
      cache_values!

      value = cache[key.to_sym].to_s.downcase

      %w{true yes 1}.include?(value) ? true : false
    end

    # Returns value casted to string array (splits string value by comma)
    def a(key)
      cache_values!

      cache[key.to_sym].to_s.split(/\s*,\s*/)
    end

    # Returns percentage value casted to float
    def p(key, value_to_cast)
      cache_values!

      value_to_cast * cache[key.to_sym].to_i * 0.01
    end

    def []=(key, value)
      if value.nil?
        find_by_alias(key.to_s).try(:destroy)
      elsif existing = find_by_alias(key.to_s)
        existing.update_attributes(:value => value)
      else
        create(:alias => key.to_s, :value => value)
      end
    end

    def [](key)
      find_by_alias(key.to_s).try(:value)
    end
  end

  protected

  def restart_server
    Rails.restart!
  end
end
