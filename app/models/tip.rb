class Tip < ActiveRecord::Base
  def self.random
    first(:offset => rand(Tip.count))
  end
end
