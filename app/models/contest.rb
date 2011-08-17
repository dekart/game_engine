class Contest < ActiveRecord::Base
  CONTEXTS = {
    :fights_won             => :fights, 
    :total_monsters_damage  => :monsters
  }
  
  has_many :groups, 
    :class_name => "ContestGroup",
    :dependent => :destroy
  
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
      contest.finished_at = Time.now if Time.now < contest.finished_at 
    end
    
    after_transition :on => :finish do |contest|
      Character.transaction do
        winners = contest.apply_payouts
        contest.send_notifications_to_winners(winners)
        
        winners.each {|c| c.save! }
      end
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
    
  after_create :create_initial_group!
  
  def context
    CONTEXTS[points_type.to_sym]
  end

  def started?
    visible? && started_at <= Time.now
  end
  
  def starting_soon?
    visible? && started_at > Time.now
  end
  
  def time_left_to_start
    (started_at - Time.now).to_i
  end
  
  def time_left_to_finish
    (finished_at - Time.now).to_i
  end
  
  def available?
    started? || finished?
  end
  
  def active?
    started? && time_left_to_finish >= 0
  end
  
  def group_for(character)
    unless group = character.contest_groups.first(:conditions => {:contest_id => id})
      groups = self.groups.all(:order => 'max_character_level')
      
      group = groups.detect{|g| g.max_character_level >= character.level if g.max_character_level }
      group ||= groups.detect{|g| g.max_character_level.nil? }
    end
    
    group
  end
  
  def groups_in_natural_order
    groups.sort do |a, b|
     a_max_character_level = a.max_character_level || Float::MAX
     b_max_character_level = b.max_character_level || Float::MAX
     
     a_max_character_level <=> b_max_character_level
   end
  end
  
  def result_for(character)
    group_for(character).result_for(character)
  end
  
  def position(character)
    group_for(character).position(character)
  end
  
  def payouts_for(character)
    group_for(character).payouts_for(character)
  end
  
  def inc_points!(character, points = 1)
    if active?
      contest_group = group_for(character)
      
      contest_group.transaction do
        character_contest_group = contest_group.character_contest_groups.find_or_create_by_character_id(character.id)
        
        character_contest_group.points += points
        
        character_contest_group.save!
      end
    end
  end
  
  def apply_payouts
    winners = []
    
    groups.each do |group|
      winners << group.apply_payouts
    end
    
    winners.flatten!
    
    winners
  end
  
  def apply_payouts!
    winners = apply_payouts
    
    if winners.any?
      Character.transaction do 
        winners.each {|c| c.save!}
      end
    end
    
    winners
  end
  
  def send_notifications_to_winners(winners)
    winners.each do |winner|
      winner.notifications.schedule(:contest_winner, :contest_id => id)
    end
  end
  
  protected
  
    def started_at_set?
      !self.started_at.nil?
    end
    
    def create_initial_group!
      groups.create!
    end
  
end