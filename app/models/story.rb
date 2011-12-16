class Story < ActiveRecord::Base
  extend HasPayouts
  extend HasPictures
  
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
  
  has_pictures :styles => [
    [:original,   "90x90#"]
  ]
    
  has_payouts :visit

  validates_presence_of :alias, :title, :description, :action_link
  
  def interpolate(attribute, options = {})
    if attribute.is_a?(Array)
      attribute.collect{|a| interpolate(a, options) }
    else
      raise ArgumentError.new("#{attribute} is not available for interpolation") unless [:title, :description, :action_link, :payout_message].include?(attribute.to_sym)

      if attribute_value = send(attribute).dup and !attribute_value.blank?
        options.each do |key, value|
          attribute_value.gsub!(/%\{#{key}\}/, value.to_s)
        end
      
        attribute_value
      else
        nil
      end
    end
  end
  
  TYPE_TO_REFERENCE = {
    'level_up'                  => :level,
    'item_purchased'            => :item_id,
    'mission_help'              => :mission_id,
    'mission_completed'         => :mission_id,
    'boss_defeated'             => :boss_id,
    'monster_invite'            => :monster_id,
    'monster_defeated'          => :monster_id,
    'property'                  => :property_id,
    'promotion'                 => :promotion_id,
    'hit_listing_new'           => :hit_listing_id,
    'hit_listing_completed'     => :hit_listing_id,
    'collection_completed'      => :collection_id,
    'collection_missing_items'  => :collection_id,
    'achievement'               => :achievement_type_id
  }
  
  def track_visit!(character, story_data = {})
    reference = story_data[TYPE_TO_REFERENCE[self.alias]]
    
    visit_attributes = {
      :character_id => character.id, 
      :story_alias  => self.alias, 
      :reference_id => reference, 
      :publisher_id => story_data[:character_id]
    }
    
    if StoryVisit.first(:conditions => visit_attributes)
      []
    else
      transaction do
        visit = StoryVisit.create!(visit_attributes)
        
        if visit.character_id != visit.publisher_id
          payouts.apply(character, :visit, self).tap do
            character.save
          end
        else
          []
        end
      end
    end
  end
  
  def name
    '%s #%d (%s)' % [self.class.human_name, id, self.alias]
  end
end
