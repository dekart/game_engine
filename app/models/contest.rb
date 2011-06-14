class Contest < ActiveRecord::Base
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
    :conditions => ["state = 'visible' OR (state = 'finished' AND finished_at <= ?)", 
      Setting.i(:contests_show_after_finished_time).days.since] 
  }
    
  
  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x120>",
      :normal => "200x200>",
      :large  => "350x350>",
      :stream => "90x90#"
    }
  
  validates_presence_of :name, :description
  
  validates_numericality_of :duration_time, 
    :greater_than => 0

  def leaders(options = {})
    options.reverse_merge!({
      :include => :character,
      :order => 'current_points DESC'
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
    visible? && !finished? && started_at <= Time.now
  end
  
  def starting_soon?
    visible? && started_at >= Time.now
  end

  def position(character)
    character_contest = character.character_contests.first(
      :select => 'current_points', 
      :conditions => {:contest_id => id}
    )
    
    @conditions = ['current_points > ?', character_contest.current_points] if character_contest
    
    character_contests.count(:conditions => @conditions) + 1
  end
  
  def time_left_to_start
    (Time.now - started_at).to_i
  end
  
  def time_left_to_finish
    (finished_at - Time.now).to_i
  end
  
  protected
  
    def started_at_set?
      !self.started_at.nil?
    end
  
end