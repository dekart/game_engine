class User < ActiveRecord::Base
  has_one :character, :dependent => :destroy

  has_many :invitations, 
    :foreign_key  => :sender_id,
    :dependent    => :destroy,
    :extend       => User::Invitations

  named_scope :after, Proc.new{|user|
    {
      :conditions => ["id > ?", user.is_a?(User) ? user.id : user.to_i],
      :order      => "id ASC"
    }
  }
  
  attr_accessible :show_next_steps

  class << self
    def reference_stats(time_limit = 0)
      scope = self

      if time_limit
        scope = scope.scoped(:conditions => ["created_at > ?", time_limit])
      end
      
      scope.all(:select => "reference, count(id) as user_count", :group => :reference, :order => :reference).collect{|c|
        [c.reference, c[:user_count].to_i]
      }
    end
  end

  def show_tutorial?
    Setting.b(:user_tutorial_enabled) && self[:show_tutorial]
  end

  def customized?
    true
  end

  def touch!
    update_attribute(:updated_at, Time.now)
  end

  def should_visit_landing_page?
    (landing_visited_at || created_at) < Setting.i(:landing_pages_visit_delay).hours.ago
  end

  def visit_landing!(name)
    self.landing_visited_at = Time.now
    self.last_landing = name.to_s

    save
  end

  def admin?
    Setting.a(:user_admins).include?(facebook_id.to_s)
  end
end
