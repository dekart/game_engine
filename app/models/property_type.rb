class PropertyType < ActiveRecord::Base
  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x>"
    }

  named_scope :available_for, Proc.new {|character|
    {
      :conditions => ["level <= ?", character.level],
      :order      => :basic_price
    }
  }

  serialize :requirements, Requirements::Collection

  def requirements
    super || Requirements::Collection.new
  end

  def requirements=(collection)
    unless collection.is_a?(Requirements::Collection)
      items = collection.values.collect do |requirement|
        Requirements::Base.by_name(requirement[:type]).new(requirement[:value])
      end

      collection = Requirements::Collection.new(*items)
    end

    super(collection)
  end
end
