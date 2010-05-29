module DesignHelper
  def hide_block_link(id)
    link_to_remote(t("blocks.hide"),
      :url    => hide_block_user_path(current_user, :block => id),
      :before => "$('##{id}').hide()",
      :html   => {:class => :hide}
    )
  end

  def title(text)
    content_tag(:h1, text, :class => :title)
  end

  def button(key, options = {})
    asset_key = "buttons_#{scope_key_by_partial(".#{key}").gsub(/\./, "_")}"
    label = key.is_a?(Symbol) ? t(".buttons.#{key}", options) : key

    if !options[:disable_asset] and asset = Asset[asset_key]
      image_tag(asset.image.url, :alt => label)
    else
      content_tag(:span, label)
    end
  end

  def percentage_bar(percentage, options = {})
    returning result = "" do
      result << content_tag(:div, options.delete(:label), :class => :text) if options[:label]

      result << content_tag(:div,
        content_tag(:div, "",
          :class => "percentage #{ :complete if percentage >= 100 }",
          :style => "width: %.4f%" % percentage
        ),
        options.reverse_merge(:class => :progress_bar)
      )

      result.html_safe!
    end
  end

  def result_for(type, &block)
    concat(
      content_tag(:div, capture(&block),
        :id     => "#{type}_result",
        :class  => "result_content clearfix"
      )
    )
  end
end