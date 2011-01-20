class Story < ActiveRecord::Base
  extend HasPayouts
  
  named_scope :by_alias, Proc.new{|value|
    {
      :conditions => {:state => 'visible', :alias => value.to_s},
      :order => "RAND()"
    }
  }
  
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

  validates_presence_of :alias, :title, :description, :action_link
  
  def interpolate(attribute, options = {})
    raise ArgumentError.new("#{attribute} is not available for interpolation") unless [:title, :description, :action_link].include?(attribute.to_sym)
    
    if attribute_value = send(attribute) and !attribute_value.blank?
      options.each do |key, value|
        attribute_value.gsub!(/%\{#{key}\}/, value.to_s)
      end
      
      attribute_value
    else
      nil
    end
  end
end
