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
    self.update_attribute(:updated_at, Time.now)
  end

  def admin?
    Setting.a(:user_admins).include?(facebook_id.to_s)
  end

  def should_visit_invite_page?
    Setting.b(:user_invite_page_redirect_enabled) and
      created_at < Setting.i(:user_invite_page_first_visit_delay).hours.ago and
      (invite_page_visited_at.nil? or invite_page_visited_at < Setting.i(:user_invite_page_recurrent_visit_delay).hours.ago)
  end

  def invite_page_visited!
    update_attribute(:invite_page_visited_at, Time.now)
  end

  def should_visit_gift_page?
    Setting.b(:gifting_enabled) and
      created_at < Setting.i(:gifting_page_first_visit_delay).hours.ago and
      (gift_page_visited_at.nil? or gift_page_visited_at < Setting.i(:gifting_page_recurrent_visit_delay).hours.ago)
  end

  def gift_page_visited!
    update_attribute(:gift_page_visited_at, Time.now)
  end
end
