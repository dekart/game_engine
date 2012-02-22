module TabsHelper
  class TabsBuilder
    attr_reader :template

    delegate :dom_id, :dom_class, :capture, :concat, :javascript_tag, :current_character, :link_to, :t, :tag_options, :to => :template

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

      result << '<ul>'
      
      @tab_names.each do |id, name, url|
        result << %{<li>#{ link_to(name, url ? url : "##{id}") }</li>}
      end

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