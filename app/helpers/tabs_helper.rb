module TabsHelper
  class TabsBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :capture, :concat, :javascript_tag, :current_character, :link_to, :t, :tag_options, :to => :template

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

      result << @tab_names.map{|t| %{<li><a href="##{ t.first }">#{ t.last }</a></li>} }.join

      result << '</ul>'

      result << @tab_contents.map{|t| %{<div id="#{ t.first }">#{ capture(&t.last) }</div>} }.join

      result = (
        %{<div #{ tag_options(options) }>#{ result }</div>}
      ).html_safe

      block_given? ? concat(result) : result
    end
  end

  def tabs(options = {}, &block)
    TabsBuilder.new(self).html(options, &block)
  end
end