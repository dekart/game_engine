module InterfaceHelpers
  module MiscHelper
    ICON_EXTENSION = "gif"
    ICON_WIDTH = 16
    ICON_HEIGHT = 16
    
    def icon(name, attributes = {})
      default_options = {
        :class => "icon", 
        :width => ICON_WIDTH,
        :height => ICON_HEIGHT
      }
      
      image_tag("icons/#{name}.#{ICON_EXTENSION}", default_options.merge(attributes))
    end
    
    def flash_block(display_keys = [:success, :error, :notice])
      result = ""
      
      display_keys.each do |key|
        result << content_tag("div", flash[key], :id => :flash, :class => key) if flash[key]
      end
      
      return result
    end
  end
end