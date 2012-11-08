module DialogHelper
  class Builder
    def initialize(template, dom_id = nil)
      @template = template
      @dom_id = dom_id
    end

    def on_ready(&block)
      @on_ready = @template.capture(&block)
    end

    def html(&block)
      content = ''

      content << @template.capture(self, &block)

      content << %{<script type="text/javascript">#{ @on_ready }</script>} if @on_ready

      if @dom_id
        content = %{<div id="#{ @dom_id }">#{ content }</div>}
      end

      content.html_safe
    end
  end

  def dialog(dom_id = nil, &block)
    content = Builder.new(self, dom_id).html(&block)

    dom_ready("$(document).queue('dialog', function(){ DialogController.show('#{ escape_javascript(content).html_safe }') });")
  end
end
