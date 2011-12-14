class Picture < ActiveRecord::Base
  extend HasPictures
  
  belongs_to :owner, :polymorphic => true
  
  has_attached_file :image, 
    :styles => lambda { |attachment| attachment.instance.styles }
    
  def styles
    picture_style = owner_class.picture_options[:styles].find{|name, value| name == style.try(:to_sym)}
    
    if picture_style
      { 
        :original => picture_style[1]
      }
    else
      {}
    end
  end
  
  def owner_class
    owner_type.to_s.constantize
  end
  
  def style=(value)
    self["style"] = value.nil? ? nil : value.to_s
  end
end
