module PromoHelper
  class Builder
    attr_reader :template, :options, :context

    delegate :capture, :concat, :content_tag, :dom_ready, :to => :template

    def initialize(template, context, options = {})
      @template = template
      @context  = context
      @options  = options
      @pages    = []
    end
    
    def page(id, options = {}, &block)
      @pages << [id, block, options]
    end
    
    def html
      yield(self)
      
      content = html_for_pages

      unless content.blank?
        dom_ready('$("#promo_block").promoBlock();')
      
        content_tag(:div, content, options.reverse_merge(:id => :promo_block))
      end
    end
    
    protected
    
    def html_for_pages
      result = ""
      
      @pages.each do |id, block, options|
        if (!options.has_key?(:context) || options.has_key?(:context) && Array.wrap(options[:context]).include?(context))
          result << content_tag(:div, capture(&block), :id => "promo_block_page_#{id}", :class => 'page clearfix')
        end
      end
      
      result.html_safe
    end
  end

  def promo_block(context, options = {}, &block)
    content = Builder.new(self, context, options).html(&block)

    block_given? ? concat(content) : content
  end
end