class DivFormBuilder
  def submit_and_continue(*args)
    options = args.extract_options!
    submit_text = args.any? ? args.shift : @template.t(".submit", :default => @template.t("form_builder.submit"))
    submit_continue_text = args.any? ? args.shift : @template.t(".submit_and_continue", :default => @template.t("form_builder.submit_and_continue"))

    options.reverse_merge!(:field_type => :submit)

    field(:submit,
      @template.submit_tag(submit_text, options.except(*CUSTOM_OPTIONS)) +
      @template.submit_tag(submit_continue_text, options.except(*CUSTOM_OPTIONS).merge(:class => :submit_and_continue)),
      options.merge(:label => false)
    )
  end
end