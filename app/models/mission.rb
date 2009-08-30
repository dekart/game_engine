class Mission < ActiveRecord::Base
  extend SerializeWithPreload
  
  has_many :ranks
  belongs_to :mission_group

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x120>"
    }

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

  validates_presence_of :mission_group, :name, :success_text, :failure_text, :complete_text, :title, :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max, :allow_blank => true

  def requirements
    super || Requirements::Collection.new
  end

  def requirements=(collection)
    if collection and !collection.is_a?(Requirements::Collection)
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
    if collection and !collection.is_a?(Payouts::Collection)
      items = collection.values.collect do |payout|
        Payouts::Base.by_name(payout[:type]).new(payout.except(:type))
      end

      collection = Payouts::Collection.new(*items)
    end

    super(collection)
  end

  def money
    rand(self.money_max - self.money_min) + self.money_min
  end
end
