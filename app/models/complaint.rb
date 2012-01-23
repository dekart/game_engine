class Complaint < ActiveRecord::Base
  belongs_to :owner, :class_name => "Character"
  
  default_scope :order => "created_at DESC"
  
  state_machine :initial => :unread do
    state :read
    state :unread

    event :mark_read do
      transition :unread => :read
    end
  end
  
  validates_presence_of :description
  
  def offender
    @offender ||= Character.find(offender_id)
  end
end
