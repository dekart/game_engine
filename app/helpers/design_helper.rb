module DesignHelper
  def hide_block_link(id, options = {})
    options[:title] ||= t("blocks.hide")
    options[:url] ||= toggle_block_user_path(current_user, :block => id)
    options[:before] ||= "$('##{id}').hide()"
    options[:html] ||= {:class => :hide}
    
    link_to_remote(options[:title].html_safe, options)
  end

  def title(text)
    content_tag(:h1, text.html_safe, :class => :title)
  end

  def button(key, options = {})
    label = key.is_a?(Symbol) ? t(".buttons.#{key}", options) : key

    content_tag(:span, label.respond_to?(:html_safe) ? label.html_safe : label)
  end

  def percentage_bar(percentage, options = {})
    result = ""

    result << content_tag(:div, options.delete(:label).html_safe, :class => :text) if options[:label]

    result << content_tag(:div,
      content_tag(:div, "",
        :class => "percentage #{ :complete if percentage >= 100 }",
        :style => "width: %.4f%" % percentage
      ),
      options.reverse_merge(:class => :progress_bar)
    )

    result.html_safe
  end
end
