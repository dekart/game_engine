class MissionGroup < ActiveRecord::Base
  extend SerializeWithPreload

  has_many :missions, :dependent => :destroy

  named_scope :next_for, Proc.new{|character|
    {
      :conditions => ["mission_groups.level > ?", character.level],
      :order      => "mission_groups.level"
    }
  }
  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true
  
  serialize :payouts, Payouts::Collection

  def payouts
    super || Payouts::Collection.new
  end

  def payouts=(collection)
    if collection and !collection.is_a?(Payouts::Collection)
      items = collection.values.collect do |payout|
        Payouts::Base.by_name(payout[:type]).new(payout.except(:type))
      end

      collection = Payouts::Collection.new(*items)
    end

    super(collection)
  end
end
