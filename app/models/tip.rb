class Tip < ActiveRecord::Base
  def self.random
    self.find(:first, :offset => rand(Tip.count))
  end
end
