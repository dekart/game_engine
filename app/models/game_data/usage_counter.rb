module GameData
  class UsageCounter
    def initialize(target, name)
      @target = target
      @name = name

      @key = [target.name.demodulize.underscore, name].join('_')
    end

    def increment!(value = 1)
      $redis.hincrby(@key, @target.key, value)
    end

    def decrement!(value = 1)
      $redis.hincrby(@key, @target.key, - value)
    end

    def count
      $redis.hget(@key, @target.key).to_i
    end
  end
end