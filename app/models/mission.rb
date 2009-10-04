class Mission < ActiveRecord::Base
  extend HasPayouts
  extend HasRequirements
  
  has_many    :ranks, :dependent => :delete_all
  belongs_to  :mission_group
  belongs_to  :parent_mission, :class_name => "Mission"
  has_many    :child_missions, :class_name => "Mission", :foreign_key => "parent_mission_id", :dependent => :destroy
  has_many    :help_requests, :as => :context, :dependent => :destroy

  named_scope :available_for, Proc.new {|character|
    {
      :include => :mission_group,
      :conditions => [
        "mission_groups.level <= :level AND (missions.repeatable OR missions.id NOT IN(:completed))",
        {
          :level => character.level,
          :completed => [character.ranks.completed_mission_ids, 0].flatten
        }
      ],
      :order => "mission_groups.level, mission_groups.id"
    }
  }

  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x120>"
    }

  has_requirements
  has_payouts

  validates_presence_of :mission_group, :name, :success_text, :failure_text, :complete_text, :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max
  validates_numericality_of :win_amount, :success_chance, :ep_cost, :experience, :money_min, :money_max, :allow_blank => true

  def self.to_grouped_dropdown
    returning result = {} do
      MissionGroup.all(:order => :level).each do |group|
        result[group.name] = group.missions.collect{|i| [i.name, i.id]}
      end
    end
  end

  def money
    rand(self.money_max - self.money_min) + self.money_min
  end

  def visible_for?(character)
    self.parent_mission.nil? or character.rank_for_mission(self.parent_mission).completed?
  end
end
