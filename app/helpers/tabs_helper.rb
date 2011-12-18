module TabsHelper
  class TabsBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :content_tag, :capture, :concat, :javascript_tag, :current_character, :link_to, :t, :to => :template
    
    def initialize(template)
      @template = template
      
      @tab_names = []
      @tab_contents = []
    end
    
    def tab(id, *args, &block)
      name, url = args

      @tab_names << [id, name || t(".tabs.#{id}"), url]
      @tab_contents << [id, block]
    end
    
    def html(options)
      result = ""
      
      yield(self)
      
      headers = @tab_names.map{|id, name, url| 
        content_tag(:li, link_to(name, url ? url : "##{id}"))
      }

      tabs = @tab_contents.map{|id, block|
        unless @tab_names.assoc(id).last
          content_tag(:div, capture(&block), :id => id)
        end
      }

      result = content_tag(:div, 
        content_tag(:ul, headers.join("\n").html_safe) + tabs.join("\n").html_safe, 
        options
      )
      
      block_given? ? concat(result) : result
    end
  end
  
  def tabs(options = {}, &block)
    TabsBuilder.new(self).html(options, &block)
  end
end