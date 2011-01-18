class Story < ActiveRecord::Base
  extend HasPayouts
  
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
  end
  
  has_attached_file :image,
    :styles     => {:original => "90x90#"},
    :removable  => true
    
  has_payouts :visit

  validates_presence_of :alias, :title
end
