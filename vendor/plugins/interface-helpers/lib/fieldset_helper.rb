module InterfaceHelpers
  module FieldsetHelper
    class FieldsetBuilder
      DEFAULT_CLASSES = {
        :fieldset => "fieldset",
        :field => "field",
        :label => "label",
        :value => "value"
      }
      
      def initialize(template, options = {})
        @config = DEFAULT_CLASSES.merge(options)

        @template = template
      end

      def pre_wrapper
        "<div class=\"#{@config[:fieldset]}\">"
      end

      def post_wrapper
        "</div>"
      end

      def field(label, value, options = {})
        @template.content_tag(:div,
          @template.content_tag(:div, label, :class => @config[:label]) +
          @template.content_tag(:div, value, :class => @config[:value]),
          :class => options[:class] || @config[:field]
        )
      end
    end
    
    def fieldset(options = {}, &block)
      fieldset_builder = InterfaceHelpers::FieldsetHelper::FieldsetBuilder.new(self, options)
      concat(fieldset_builder.pre_wrapper, block.binding)
      yield fieldset_builder
      concat(fieldset_builder.post_wrapper, block.binding)
    end
  end
end