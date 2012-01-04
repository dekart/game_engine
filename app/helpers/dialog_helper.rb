module DialogHelper
  class Builder
    def initialize(template, dialog_id = nil)
      @template = template
      @dialog_id = dialog_id
    end

    def on_ready(&block)
      @on_ready = @template.capture(&block)
    end

    def html(&block)
      content = ''

      content << @template.capture(self, &block)

      content << ('<script type="text/javascript">%s</script>' % @on_ready) if @on_ready

      if @dialog_id
        content = '<div id="%s">%s</div>' % [
          @dialog_id,
          content
        ]
      end

      content.html_safe
    end
  end

  def dialog(dialog_id = nil, &block)
    content = Builder.new(self, dialog_id).html(&block)

    dom_ready("$(document).queue('dialog', function(){ $.dialog('#{escape_javascript(content).html_safe}') });")
  end
end
