class Mission < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  extend HasPictures
  include HasVisibility

  has_many    :levels, :class_name => "MissionLevel", :dependent => :destroy
  has_many    :ranks, :class_name => "MissionRank", :dependent => :delete_all
  belongs_to  :mission_group
  belongs_to  :parent_mission, :class_name => "Mission"
  has_many    :child_missions, :class_name => "Mission", :foreign_key => "parent_mission_id", :dependent => :destroy

  acts_as_list :scope => 'mission_group_id = #{mission_group_id} AND missions.state != \'deleted\''

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

    after_transition :to => :deleted do |mission|
      Mission.update_all(
        "position = (position - 1)", "missions.state != \'deleted\' AND position > #{mission.position}"
      )
      mission.update_attribute(:position, nil)
    end
  end

  has_pictures :styles => [
    [:small,  "120x120>"],
    [:stream, "90x90#"],
    [:icon,   "50x50>"]
  ]

  has_requirements
  
  has_payouts(MissionLevel.payout_events + [:mission_complete],
    :apply_on => :mission_complete
  )

  validates_presence_of :mission_group, :name
  
  after_update :update_group_in_ranks, :if => :mission_group_id_changed?
  
  class << self
    def available_for(character)
      with_state(:visible).visible_for(character)
    end
  end

  def self.to_grouped_dropdown
    {}.tap do |result|
      MissionGroup.without_state(:deleted).each do |group|
        result[group.name] = group.missions.without_state(:deleted).collect{|i|
          [i.name, i.id]
        }
      end
    end
  end

  def visible_for?(character)
    parent_mission.nil? or character.missions.rank_for(parent_mission).completed?
  end
  
  def applicable_payouts
    payouts + mission_group.applicable_payouts
  end
  
  def applicable_requirements
    requirements + mission_group.requirements
  end
  
  protected
  
  def update_group_in_ranks
    ranks.update_all :mission_group_id => mission_group_id
  end
end
