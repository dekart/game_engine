class Translation < ActiveRecord::Base
  validates_presence_of :key, :value

  after_save :restart_server
  after_destroy :restart_server
  
  def self.to_hash
    retuning result = {} do
      all.each do |translation|
        result.deep_merge!(translation.to_hash)
      end
    end
  end

  def to_hash
    inject_key do |hash, key, last|
      hash[key] = last ? value : {}
    end
  end

  def inject_key
    key_parts = key.split(".")

    result = init = {}
    key_parts.each_with_index do |item, index|
      result = yield(result, item, index == key_parts.size - 1)
    end
    init
  end

  private

  def restart_server
    Rails.restart!
  end
end
