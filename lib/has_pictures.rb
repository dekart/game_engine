module HasPictures
  def has_pictures(*args)
    options = args.empty? ? {:styles => []} : args.extract_options!
    
    cattr_accessor :picture_options
    self.picture_options = options
    
    has_many :pictures, :as => :owner, :extend => Pictures::Collection
    
    send(:include, InstanceMethods)
    
    after_save :create_missing_picture_styles
  end
  
  def picture_styles_for_select
    picture_options[:styles].collect{|name, value| [name.to_s.humanize, name.to_s] }
  end
  
  module InstanceMethods
    def picture_attributes
      pictures.map{|p| p.attributes}
    end
    
    def picture_attributes=(collection)
      collection = collection.values if collection.is_a?(Hash)
      
      collection.each do |attributes|
        attributes.symbolize_keys!

        picture_id = attributes.delete(:id)
        remove     = attributes.delete(:_destroy)
        image      = attributes.delete(:image)
        
        if picture_id && !picture_id.blank?
          picture = pictures.find(picture_id)
        elsif !image.blank?
          picture = pictures.build
        end
        
        if picture
          if !remove.blank?
            picture.destroy unless picture.new_record?
          else
            attributes[:style] ||= pictures.default_style

            picture.attributes = attributes
            picture.image      = image unless image.blank?
            
            picture.save if picture.changed?
          end
        end
      end
      
      pictures.clear_url_cache!
    end
    
    def pictures?
      !pictures.empty? && pictures.first.image?
    end
    
    def create_missing_picture_styles
      missing_styles = picture_options[:styles].collect{|name, value| name } - 
                       pictures(true).collect{|picture| picture.style.try(:to_sym) }
      
      if missing_styles.any? and pictures.any?
        original = pictures.sort_by_style.first
        
        missing_styles.each do |style|
          picture = pictures.build(:style => style)
          picture.image = original.image.to_file
          
          picture.save
        end
      end
      
      pictures.clear_url_cache!
    end
  end
end
