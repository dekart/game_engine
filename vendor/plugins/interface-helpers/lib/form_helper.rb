module InterfaceHelpers
  class FormBuilder < ActionView::Helpers::FormBuilder
    (field_helpers + %w(date_select datetime_select) - %w(hidden_field)).each do |selector| 
      src = <<-END_SRC 
        def #{selector}(label, field, options = {}, &block)
          field = field.to_s

          generic_field_options = extract_options(options)
          generic_field_options[:label] = label
          generic_field_options[:comment] = @template.capture(&block) if block_given?

          result = generic_field(field, super(field, options), generic_field_options)

          block_given? ? @template.concat(result, block.binding) : result
        end 
      END_SRC
      class_eval src, __FILE__, __LINE__ 
    end

    def select(label, field, choises, options = {}, html_options = {}, &block)
      field = field.to_s

      generic_field_options = extract_options(options)
      generic_field_options[:label] = label
      generic_field_options[:comment] = @template.capture(&block) if block_given?

      result = generic_field(field, super(field, choises, options, html_options), generic_field_options)

      block_given? ? @template.concat(result, block.binding) : result
    end

    def radio_button(label, field, choises, options = {}, &block)
      field = field.to_s

      generic_field_options = extract_options(options)
      generic_field_options[:label] = label
      generic_field_options[:comment] = @template.capture(&block) if block_given?
      
      result = ""
      choises.each do |choise|
        result << div(
          div(super(field, choise[1], options), :class => :option_input) + 
          div(choise[0], :class => :option_label),
          :class => :option
        )
      end
      result = generic_field(field, result, generic_field_options)

      block_given? ? @template.concat(result, block.binding) : result
    end

    def submit(text, options = {})
      generic_field_options = extract_options(options)
      generic_field(nil, @template.submit_tag(text, options), generic_field_options)
    end

    def hidden_field(field, options = {})
      generic_field_options = extract_options(options)
      super
    end

    def fieldset(legend = nil, options = {}, &block)
      @template.concat(
        @template.content_tag(:fieldset,
          (legend ? @template.content_tag(:legend, legend) : "") +
          @template.capture(&block),
          options
        ),
        block.binding
      )
    end

    def generic_field(fieldname, field, options = {})
      required = options[:required] ? @template.content_tag(:span, '*', :class => 'required') : ''

      div(
        (!options[:label].blank? ? div(label(options[:label], "#{@object_name}_#{fieldname}") + required, :class => :label) : "") +
        (!options[:before_field].blank? ? div(options[:before_field], :class => :before) : "") +
        div(field, :class => :input) +
        (!options[:after_field].blank? ? div(options[:after_field], :class => :after) : "") +
        error_message_on(fieldname) +
        (!options[:comment].blank? ? div(options[:comment], :class => :comment) : ""),
        :class => :field,
        :id => options[:id] ? options[:id] : ("field_for_#{@object_name}_#{fieldname}" if !fieldname.blank?)
      )
    end

    def error_message_on(method)
      if errors = object.errors.on(method)
        error = errors.is_a?(Array) ? errors.first : errors
        error = error.call if error.respond_to?(:call)
        return div(error, :class => :error)
      else 
        return ''
      end
    end

  protected
    
    def div(content, options = {})
      @template.content_tag(:div, content, options)
    end
    
    def label(text, for_field)
      @template.content_tag('label', text, :for => for_field)
    end

    def extract_options(options)
      {
        :label => (options.delete(:label) || nil),
        :required => (options.delete(:required) || false),
        :comment => (options.delete(:comment) || false),
        :validation => (options.delete(:validate) || false),
        :before_field => (options.delete(:before_field) || ""),
        :after_field => (options.delete(:after_field) || ""),
        :id => (options.delete(:id) || nil)
      }
    end

  end
end