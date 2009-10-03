class Configuration < ActiveRecord::Base
  def self.[](key)
    find(:first).send(key)
  end
end
