class Contest < ActiveRecord::Base
  CONTEXTS = {
    :fights_won             => :fights,
    :total_monsters_damage  => :monsters
  }

  extend HasPictures

  has_many :groups,
    :class_name => "ContestGroup",
    :dependent => :destroy

  state_machine :initial => :hidden do
    state :hidden
    state :visible
    state :deleted

    event :publish do
      transition :hidden => :visible, :if => :time_frame_set?
    end

    event :hide do
      transition :visible => :hidden
    end

    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end

  scope :finished, Proc.new {
    where("finished_at < ?", Time.now)
  }

  scope :finished_recently, Proc.new{
    where(:state => 'visible').
    where("finished_at BETWEEN ? AND ?", Setting.i(:contests_show_after_finished_time).days.ago, Time.now).
    order('finished_at DESC')
  }

  scope :upcoming, Proc.new {
    where(:state => 'visible').
    where("started_at > ?", Time.now).
    order('started_at')
  }

  has_pictures :styles => [
    [:promo, "760x>"],
    [:stream, "90x90#"]
  ]

  validates_presence_of :name, :points_type, :description_before_started, :description_when_started, :description_when_finished

  after_create :create_initial_group!

  class << self
    def current
      where("state='visible' AND (? BETWEEN started_at AND finished_at)", Time.now).first
    end

    def visible
      current || upcoming.first || finished_recently.first
    end

    def points_type_to_dropdown
      Contest::CONTEXTS.keys.map{|k| k.to_s}
    end
  end

  def context
    CONTEXTS[points_type.to_sym]
  end

  def started?
    visible? && Time.now > started_at
  end

  def finished?
    visible? and Time.now > finished_at
  end

  def time_left_to_start
    (started_at - Time.now).to_i
  end

  def time_left_to_finish
    (finished_at - Time.now).to_i
  end

  def description
    if finished?
      description_when_finished
    elsif started?
      description_when_started
    else
      description_before_started
    end
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

  def rewardable?(character)
    group_for(character).rewardable?(character)
  end

  def increment_points!(character, points = 1)
    contest_group = group_for(character)

    contest_group.transaction do
      character_contest_group = contest_group.character_contest_groups.find_or_create_by_character_id(character.id)

      character_contest_group.points += points

      character_contest_group.save!
    end
  end

  def send_finish_notification!
    update_attribute(:finish_notification_sent, true)

    groups.each do |group|
      group.characters.find_each(:batch_size => 10) do |character|
        character.notifications.schedule(:contest_finished, :contest_id => id)
      end
    end
  end

  protected

    def time_frame_set?
      !self.started_at.nil? && !self.finished_at.nil? and self.started_at < self.finished_at
    end

    def create_initial_group!
      groups.create!
    end

end
