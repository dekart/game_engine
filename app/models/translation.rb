class Translation < ActiveRecord::Base
  validates_presence_of :key, :value

  after_save :restart_server
  
  def self.to_hash
    result = {}

    self.all.each do |translation|
      result.deep_merge!(translation.to_hash)
    end

    result
  end

  def to_hash
    inject_key do |hash, key, last|
      hash[key] = last ? self.value : {}
    end
  end

  def inject_key
    key_parts = self.key.split(".")

    result = init = {}
    key_parts.each_with_index do |item, index|
      result = yield(result, item, index == key_parts.size - 1)
    end
    init
  end

  private

  def restart_server
    system("touch #{File.join(RAILS_ROOT, "tmp", "restart.txt")}")
  end
end
