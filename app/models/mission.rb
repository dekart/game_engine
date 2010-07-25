class Mission < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  include HasVisibility
  
  has_many    :ranks, :dependent => :delete_all
  belongs_to  :mission_group
  belongs_to  :parent_mission, :class_name => "Mission"
  has_many    :child_missions, :class_name => "Mission", :foreign_key => "parent_mission_id", :dependent => :destroy
  has_many    :help_requests, :as => :context, :dependent => :destroy

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

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x120>"
    }

  has_requirements
  has_payouts :success, :failure, :complete, :repeat_success, :repeat_failure,
    :default_event => :complete

  validates_presence_of :mission_group, :name, :success_text, :failure_text, :complete_text, :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max, :loot_chance, :allow_blank => true

  def self.to_grouped_dropdown
    returning result = {} do
      MissionGroup.without_state(:deleted).all(:order => :level).each do |group|
        result[group.name] = group.missions.without_state(:deleted).collect{|i| 
          [i.name, i.id]
        }
      end
    end
  end
  
  def money
    rand(money_max - money_min) + money_min
  end

  def visible_for?(character)
    parent_mission.nil? or character.rank_for_mission(parent_mission).completed?
  end

  def loot_items
    Item.find_all_by_id(loot_item_ids)
  end

  def loot_item_ids=(value)
    self[:loot_item_ids] = value.is_a?(Array) ? value.join(",") : value
  end

  def loot_item_ids
    @loot_item_ids ||= self[:loot_item_ids].to_s.split(",").collect{|i| i.to_i }
  end

  def energy_requirement
    Requirements::EnergyPoint.new(:value => ep_cost)
  end
end
