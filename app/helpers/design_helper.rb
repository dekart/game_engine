module DesignHelper
  def hide_block_link(id, options = {})
    options[:title] ||= t("blocks.hide")
    options[:before] ||= "$('##{id}').hide()"
    options[:html] ||= {:class => :hide}
    
    # TODO: remote
    options[:remote] = true

    link_to(options[:title].html_safe, toggle_block_user_path(current_user, :block => id), options)
  end

  def title(text)
    (
      %{<h1 class="title">#{ text }</h1>}
    ).html_safe
  end

  def button(key, options = {})
    label = key.is_a?(Symbol) ? t(".buttons.#{ key }", options) : key

    (
      %{<span>#{ label }</span>}
    ).html_safe
  end

  def percentage_bar(percentage, label = nil)
    result = label ? %{<div class="text">#{ label }</div>} : ''

    result << %{
      <div class="progress_bar">
        <div class="percentage #{ :complete if percentage >= 100 }" style="width: %.4f%%"></div>
      </div>
    } % percentage

    result.html_safe
  end

  def strong_tag(content)
    %{<strong>#{ content }</strong>}
  end

  def span_tag(content, klass = nil)
    %{<span class="#{ klass }">#{ content }</span>}
  end
end
