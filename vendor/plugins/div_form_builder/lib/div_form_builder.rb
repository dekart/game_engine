class DivFormBuilder < ActionView::Helpers::FormBuilder
  REQUIRED_MARK = %{<span class="required">*</span>}
  FIELD_ORDER = [:label, :required, :before_field, :input, :after_field, :error_message, :previous_value, :comment]
  CUSTOM_OPTIONS = [:label, :required, :comment, :before_field, :after_field]

  (field_helpers + %w(date_select datetime_select) - %w(hidden_field)).each do |selector|
    src = <<-END_SRC
      def #{selector}(field_name, options = {}, &block)
        field(field_name, super(field_name, options.except(CUSTOM_OPTIONS)), options, &block)
      end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  def select(field_name, choices, options = {}, html_options = {}, &block)
    field(field_name, super(field_name, choices, options.except(CUSTOM_OPTIONS), html_options), options, &block)
  end

  def grouped_select(field_name, choices, options = {}, html_options = {}, &block)
    field(field_name, @template.grouped_select(@object_name, field_name, choices, objectify_options(options.except(CUSTOM_OPTIONS)), @default_options.merge(html_options)), options, &block)
  end

  def radio_button(field_name, choises, options = {}, &block)
    code = ""
    
    choises.each do |choise|
      code << div(
        div(super(field_name, choise[1], options.except(CUSTOM_OPTIONS)), :class => :option_input) +
        div(choise[0], :class => :option_label),
        :class => :option
      )
    end

    field(field_name, code, options, &block)
  end

  def submit(*args)
    options = args.extract_options!
    text = args.any? ? args.first : @template.t(".submit")

    field(:submit, @template.submit_tag(text, options.except(CUSTOM_OPTIONS)), options.merge(:label => false))
  end

  def fields(partial = nil)
    @template.render :partial => partial || "form_fields", :locals => {:form => self}
  end

  def field_set(legend = nil, options = {}, &block)
    @template.concat(
      @template.content_tag(:fieldset,
        (legend ? @template.content_tag(:legend, legend) : "") +
        @template.capture(&block),
        options
      )
    )
  end

  def field(field_name, field, options = {}, &block)
    code = ""

    field_changes = object.changes[field_name.to_s] if @options[:show_changes]

    (options[:order] || FIELD_ORDER).each do |part|
      code << (
        case part
        when :label
          div(
            label(
              options[:label].blank? ? object.class.human_attribute_name(field_name.to_s) : options[:label],
              "#{@object_name}_#{field_name}"
            ),
            :class => :label
          ) unless options[:label] == false
        when :required
          REQUIRED_MARK if options[:required]
        when :before_field
          div(options[:before_field], :class => :before_field) unless options[:before_field].blank?
        when :input
          div(field, :class => :input)
        when :after_field
          div(options[:after_field], :class => :after) unless options[:after_field].blank?
        when :error_message
          error_message_on(field_name)
        when :previous_value
          if @options[:show_changes] && field_changes
            div(
              @template.content_tag(:span, @template.t("form_builder.previous_value"), :class => :label) + 
              " " +
              @template.content_tag(:span, field_changes.first, :class => :value),
              :class => :previous_value
            )
          end
        when :comment
          div(options[:comment], :class => :comment) unless options[:comment].blank?
        end
      ).to_s
    end

    field_class = "field"

    if @options[:show_changes] && field_changes
      field_class << " changed" unless field_changes.first.blank? && field_changes.last.blank?
    end

    code = div(code,
      :class  => field_class,
      :id     => options[:id] || ("field_for_#{@object_name}_#{field_name}" unless field_name.blank?)
    )
    
    block_given? ? @template.concat(code) : code
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
    @template.content_tag(:label, text, :for => for_field)
  end

end