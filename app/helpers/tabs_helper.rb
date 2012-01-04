module TabsHelper
  class TabsBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :capture, :concat, :javascript_tag, :current_character, :link_to, :t, :to => :template

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

      result << '<ul>'

      result << @tab_names.map{|t| '<li>%s</li>' % link_to(t.last, "#" << t.first) }

      result << '</ul>'

      result << @tab_contents.map{|t| '<div id="%s"></div>' % [t.first, capture(&t.last)] }

      result = (
        '<div %s>%s</div>' % [
          tag_options(options),
          result
        ]
      ).html_safe

      block_given? ? concat(result) : result
    end
  end

  def tabs(options = {}, &block)
    TabsBuilder.new(self).html(options, &block)
  end
end