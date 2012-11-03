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
        result << %{<li class="tab" data-tab="#{ id }"}
        result << %{ data-url="#{ url }"} if url
        result << %{>#{name}</li>}
      end

      result << '</ul>'

      @tab_contents.each do |id, block|
        result <<  %{<div class="tab_content" id="#{ id }">#{ capture(&block) }</div>}
      end

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