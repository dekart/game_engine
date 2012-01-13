module PromoHelper
  class Builder
    attr_reader :template, :context

    delegate :capture, :concat, :dom_ready, :to => :template

    def initialize(template, context)
      @template = template
      @context  = context
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

        (
          %{<div id="promo_block">#{ content }</div>}
        ).html_safe
      end
    end

    protected

    def html_for_pages
      result = ""

      pages_to_show = @pages.select { |id, block, options|
        !options.has_key?(:context) ||
        options.has_key?(:context) &&
        Array.wrap(options[:context]).include?(context)
      }

      if pages_to_show.size > 1
        result << '<div class="previous"></div>'
        result << '<div class="next"></div>'
      end

      pages_to_show.each do |id, block, options|
        result << %{<div id="promo_block_page_#{ id }" class="page clearfix">#{ capture(&block) }</div>}
      end

      result.html_safe
    end
  end

  def promo_block(context, &block)
    content = Builder.new(self, context).html(&block)

    block_given? ? concat(content) : content
  end
end