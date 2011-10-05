module TabsHelper
  class TabsBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :content_tag, :capture, :concat, :javascript_tag, :current_character, :link_to, :t, :to => :template
    
    def initialize(template)
      @template = template
      
      @tab_names = []
      @tab_contents = []
    end
    
    def tab(id, name = nil, &block)
      @tab_names << [id, name || t(".tabs.#{id}")]
      @tab_contents << [id, block]
    end
    
    def html(options)
      result = ""
      
      yield(self)
      
      headers = @tab_names.map{|t| content_tag(:li, link_to(t.last, "#" << t.first))}.join("\n")
      result << content_tag(:ul, headers.html_safe) 
      
      result << @tab_contents.map{|t| content_tag(:div, capture(&t.last), :id => t.first)}.join("\n")
      
      result = content_tag(:div, result.html_safe, options)
      
      block_given? ? concat(result) : result
    end
  end
  
  def tabs(options = {}, &block)
    TabsBuilder.new(self).html(options, &block)
  end
end