class MissionGroup < ActiveRecord::Base
  has_many :missions, :dependent => :nullify

  validates_presence_of :name, :level
  validates_numericality_of :level, :allow_nil => true
end
