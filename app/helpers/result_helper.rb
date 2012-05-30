module ResultHelper
  class Builder
    attr_reader :template, :options, :type

    delegate :capture, :concat, :dom_ready, :to => :template

    def initialize(template, type, options = {})
      @template = template
      @type     = type
      @options  = options
    end

    def title(content = nil, &block)
      content ||= capture(&block)

      result = (
        %{<h2>#{ content }</h2>}
      ).html_safe

      block_given? ? concat(result) : result
    end

    def message(type = nil, content = nil, &block)
      @message = {
        :content  => content || capture(&block),
        :type     => type
      }
    end

    def notice(content = nil, &block)
      message(nil, content, &block)
    end

    def success(content = nil, &block)
      message(:success, content, &block)
    end

    def fail(content = nil, &block)
      message(:fail, content, &block)
    end

    def render(path, options = {})
      @template.render(path, options.merge(:builder => self))
    end

    def buttons(content = nil, &block)
      @buttons ||= ""
      @buttons << (content || capture(&block))
    end

    def on_ready(content = nil, &block)
      @on_ready ||= ""
      @on_ready << (content || capture(&block)) << ";"
      
      nil
    end

    def help_link(*args)
      @help_link = args
    end

    def html(content = nil, &block)
      content ||= capture(self, &block)

      dom_ready(@on_ready)
      dom_ready("$(document).trigger('result.#{options[:inline] ? :available : :received}');")

      (
        %{
          <div id="#{ type }_result" class="result_content clearfix">
            #{ message_html }
            #{ help_link_html }
            #{ buttons_html }
            #{ content }
          </div>
        }
      ).html_safe
    end

    protected

    def buttons_html
      unless @buttons.blank?
        (
          %{<div class="buttons clearfix">#{ @buttons }</div>}
        ).html_safe
      end
    end

    def message_html
      unless @message.blank?
        (
          %{<div class="#{ @message[:type] } message">#{ @message[:content] }</div>}
        ).html_safe
      end
    end

    def help_link_html
      unless @help_link.blank?
        (
          %{<div class="help">#{ @template.help_link(*@help_link) }</div>}
        ).html_safe
      end
    end
  end

  def result_for(*args, &block)
    options = args.extract_options!
    type, content = args

    Builder.new(self, type, options).html(content, &block)
  end

  def render_to_result(*args, &block)
    dom_ready("$('#result').html('#{ escape_javascript(result_for(*args, &block)) }');")
  end
end
