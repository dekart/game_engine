class Contest < ActiveRecord::Base
  CONTEXTS = {
    :fights_won             => :fights, 
    :total_monsters_damage  => :monsters
  }
  
  has_many :character_contests
    
  has_many :characters, 
    :through => :character_contests
  
  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :finished
    
    event :publish do
      transition :hidden => :visible, :if => :started_at_set? 
    end
    
    event :finish do
      transition :visible => :finished
    end
    
    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
    
    before_transition :on => :publish do |contest|
      contest.finished_at = contest.started_at + contest.duration_time.days
    end
    
    before_transition :on => :finish do |contest|
      contest.finished_at = Time.now
    end
  end

  named_scope :current, {
    :conditions => ["state = 'visible' OR (state = 'finished' AND finished_at > ?)", 
      Setting.i(:contests_show_after_finished_time).days.ago] 
  }
    
  has_attached_file :image
    
  validates_presence_of :name, :description, :points_type
  
  validates_numericality_of :duration_time, 
    :greater_than => 0
    
  def context
    CONTEXTS[points_type.to_sym]
  end

  def leaders_with_points(options = {})
    options.reverse_merge!({
      :include => :character,
      :order => 'points DESC'
    })
    
    character_contests.scoped(options)
  end
  
  def in_leaders?(character)
    leaders.exists?(:character_id => character.id)
  end
  
  def result_for(character)
    character_contests.first(:conditions => {:character_id => character.id})
  end

  def started?
    visible? && started_at <= Time.now
  end
  
  def starting_soon?
    visible? && started_at > Time.now
  end
  
  def position(character)
    character_contest = character.character_contests.first(
      :select => 'points', 
      :conditions => {:contest_id => id}
    )
    
    @conditions = ['points > ?', character_contest.points] if character_contest
    
    character_contests.count(:conditions => @conditions) + 1
  end
  
  def time_left_to_start
    (started_at - Time.now).to_i
  end
  
  def time_left_to_finish
    (finished_at - Time.now).to_i
  end
  
  def inc_points!(character, points = 1)
    if active?
      character_contest = character_contests.find_or_create_by_character_id(character.id)
      character_contest.points += points
      character_contest.save!
    end
  end
  
  def available?
    started? || finished?
  end
  
  def active?
    started? && time_left_to_finish >= 0
  end
  
  protected
  
    def started_at_set?
      !self.started_at.nil?
    end
  
end