class Message < ActiveRecord::Base
  validates_presence_of :content, :min_level
  validates_numericality_of :min_level
  
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

  scope :by_level, Proc.new{ |level|
    {:conditions => ["min_level <= ?", level]}
  }

  def mark_displayed(character)
    $redis.zadd("info_message_#{id}", Time.now.to_i, character.id)
  end

  def displayed_to_character?(character)
    !$redis.zscore("info_message_#{id}", character.id).nil?
  end

  def amount_displayed
    $redis.zcard("info_message_#{id}")
  end

  def amount_displayed_today
    $redis.zcount("info_message_#{id}", 24.hours.ago.to_i, Time.now.to_i)
  end
end
