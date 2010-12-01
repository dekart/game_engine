class Boost < ActiveRecord::Base

  has_many :purchased_boosts, :dependent => :destroy

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
    :styles => {
      :icon   => "40x40#",
      :small  => "72x72#",
      :medium => "120x120#",
      :large  => "200x200#",
      :stream => "90x90#"
    },
    :removable => true

  validates_presence_of :name, :level
  validates_numericality_of :level, :basic_price, :vip_price, :allow_blank => true

  class << self
    def to_dropdown(*args)
      without_state(:deleted).all(:order => :name).to_dropdown(*(args.any? ? args : :name))
    end
  end

  def price?
    basic_price > 0 or vip_price > 0
  end
end
