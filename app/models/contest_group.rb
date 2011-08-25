class ContestGroup < ActiveRecord::Base
  extend HasPayouts
  
  POSITION_TO_SYM = {
    1 => :first,
    2 => :second,
    3 => :third
  }
  
  belongs_to :contest
  
  has_many :character_contest_groups, 
    :dependent => :delete_all
  
  has_many :characters, 
    :through => :character_contest_groups
  
  has_payouts POSITION_TO_SYM.values
  
  validates_uniqueness_of :max_character_level, :scope => :contest_id
  
  validates_numericality_of :max_character_level,
    :only_integer => true, 
    :greater_than => 0, 
    :allow_nil => true
    
  validates_presence_of :contest_id
  
  def leaders_with_points(options = {})
    options.reverse_merge!(
      :include => :character,
      :order => 'points DESC'
    )
    
    character_contest_groups.scoped(:conditions => ["character_id NOT IN (?)", Character.banned_ids]).scoped(options)
  end
  
  def leaders_with_points_for_rating
    leaders_with_points(:limit => Setting.i(:contests_leaders_show_limit))
  end
  
  def winners_with_points
    leaders_with_points(:limit => POSITION_TO_SYM.length)
  end
  
  def result_for(character)
    character_contest_groups.first(:conditions => {:character_id => character.id})
  end
  
  def position(character)
    character_contest_group = contest.group_for(character)
    
    @conditions = ['points > ?', character_contest_group.points] if character_contest_group.points > 0
    
    leaders_with_points.count(:conditions => @conditions) + 1
  end
  
  def apply_payouts
    winners = []
    
    if payouts and winners_with_points = leaders_with_points.all(:limit => 3) and winners_with_points.any?
      winners = winners_with_points.map {|w| w.character }
      
      winners.each_with_index do |winner, i|
        payouts.apply(winner, POSITION_TO_SYM[i + 1])
      end
    end
    
    winners
  end
  
  def apply_payouts!
    winners = apply_payouts
    
    Character.transaction do
      winners.each {|c| c.save!}
    end
    
    winners
  end
  
  def payouts_for(character)
    payouts_for_position(position_sym(character))
  end
  
  def previous_group
    conditions = begin
      if max_character_level 
        ['max_character_level < ? AND max_character_level IS NOT NULL', max_character_level]
      else 
        'max_character_level IS NOT NULL'
      end
    end
    
    contest.groups.first(:conditions => conditions, :order => 'max_character_level DESC')
  end
  
  def start_level
    if previous = previous_group
      previous.max_character_level + 1
    else
      1
    end
  end
  
  def title
    if max_character_level
      I18n.t("contest_groups.title.level_from_to",
        :from => start_level,
        :to   => max_character_level
      )
    else
      I18n.t("contest_groups.title.level_to", :from => start_level)
    end
  end
  
  def payouts_for_position(position)
    position = POSITION_TO_SYM[position] if position.is_a?(Integer)
    
    payouts.find_all(position) if position
  end
  
  protected
    
    def position_sym(character)
      POSITION_TO_SYM[position(character)]
    end
    
end