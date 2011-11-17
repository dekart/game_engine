class Tip < ActiveRecord::Base
  acts_as_taggable
  
  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end

  validates_presence_of :text
  
  def self.random
    first(:offset => rand(Tip.count))
  end
end
