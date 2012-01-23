class Complaint < ActiveRecord::Base
  belongs_to :owner, :class_name => "Character"
  
  state_machine :initial => :unread do
    state :read
    state :unread
    state :deleted

    event :read do
      transition :unread => :read
    end
    
    event :mark_deleted do
      transition(any - [:deleted] => :deleted)
    end
  end
  
  validates_presence_of :description
  
  def offender
    @offender ||= Character.find(offender_id)
  end
end
