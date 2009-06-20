class Mission < ActiveRecord::Base
  extend SerializeWithPreload
  
  has_many :ranks
  belongs_to :mission_group

  named_scope :available_for, Proc.new {|character|
    {
      :include => :mission_group,
      :conditions => [
        "mission_groups.level <= :level AND missions.id NOT IN(:completed)",
        {
          :level => character.level,
          :completed => [character.ranks.completed_mission_ids, 0].flatten
        }
      ],
      :order => "mission_groups.level, mission_groups.id"
    }
  }

  serialize :requirements, Requirements::Collection
  serialize :payouts, Payouts::Collection

  def requirements
    super || Requirements::Collection.new
  end

  def requirements=(collection)
    unless collection.is_a?(Requirements::Collection)
      items = collection.values.collect do |requirement|
        Requirements::Base.by_name(requirement[:type]).new(requirement[:value])
      end
      
      collection = Requirements::Collection.new(*items)
    end

    super(collection)
  end

  def payouts
    super || Payouts::Collection.new
  end

  def payouts=(collection)
    unless collection.is_a?(Payouts::Collection)
      items = collection.values.collect do |payout|
        Payouts::Base.by_name(payout[:type]).new(payout[:value], payout[:options])
      end

      collection = Payouts::Collection.new(*items)
    end

    super(collection)
  end
end
