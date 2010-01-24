class ItemGroup < ActiveRecord::Base
  has_many :items, :dependent => :destroy

  acts_as_list

  named_scope :visible_in_shop, :conditions => "display_in_shop = 1", :order => "position"

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

  validates_uniqueness_of :name
end
