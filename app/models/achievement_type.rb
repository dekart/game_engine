class AchievementType < ActiveRecord::Base
  extend HasPayouts
  
  KEYS = [:level, :fights_won, :total_money, :killed_monsters_count, :total_monsters_damage]
  
  default_scope :order => "achievement_types.key, value"

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
    
    after_transition :on => :publish, :do => :schedule_registration
  end

  has_attached_file :image,
    :styles => {
      :icon   => "50x50>",
      :small  => "100x100#",
      :medium => "150x150#",
      :stream => "90x90#"
    },
    :removable => true

  has_payouts :achieve, :visible => true

  validates_presence_of     :key, :value, :name, :description
  validates_numericality_of :value, :allow_blank => true
  
  class << self
    def index
      $memory_store.fetch('achievement_types', :expires_in => 1.minute) do
        {}.tap do |result|
          with_state(:visible).each do |type|
            result[type.key] ||= []
            result[type.key] << [type.value, type.id]
          end
        end
      end
    end
  end
  
  def key
    self[:key].try(:to_sym)
  end
  
  def url
    "#{ Facepalm::Config.default.callback_url('https://') }/achievements/#{ id }"
  end
  
  def register_in_facebook!
    Facepalm::Config.default.api_client.put_connections(Facepalm::Config.default.app_id, :achievements, 
      :achievement    => url, 
      :display_order  => id
    )
  end
  
  def schedule_registration
    Delayed::Job.enqueue Jobs::AchievementTypeRegistration.new(id)
  end
end
