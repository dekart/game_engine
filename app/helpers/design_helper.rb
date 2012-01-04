module DesignHelper
  def hide_block_link(id, options = {})
    options[:title] ||= t("blocks.hide")
    options[:url] ||= toggle_block_user_path(current_user, :block => id)
    options[:before] ||= "$('##{id}').hide()"
    options[:html] ||= {:class => :hide}

    link_to_remote(options[:title].html_safe, options)
  end

  def title(text)
    (
      '<h1 class="title">%s</h1>' % text
    ).html_safe
  end

  def button(key, options = {})
    label = key.is_a?(Symbol) ? t(".buttons.#{ key }", options) : key

    (
      '<span>%s</span>' % label
    ).html_safe
  end

  def percentage_bar(percentage, label = nil)
    result = label ? ('<div class="text">%s</div>' % label) : ''

    result << '<div class="progress_bar"><div class="percentage %s" style="width: %.4f%%"></div></div>' % [
      percentage >= 100 ? 'complete': '',
      percentage
    ]

    result.html_safe
  end

  def strong_tag(content)
    '<strong>%s</strong>' % content
  end

  def span_tag(content, klass = nil)
    '<span class="%s">%s</span>' % [klass, content]
  end
end
