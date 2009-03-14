# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def fb_app_name(options = {:linked => false})
    tag("fb:application-name", options)
  end

  def fb_header(text, options = {})
    content_tag("fb:header", text, options.reverse_merge(:icon => false))
  end

  def fb_date(date, format, options = {})
    date = date.to_time unless date.is_a?(DateTime)

    tag("fb:date",
      options.merge(
        :t => date.to_i,
        :format => format
      )
    )
  end

  def fb_wallpost_action(text, link)
    content_tag("fb:wallpost-action", text, :href => link)
  end

  def fb_if_section_not_added(section, &block)
    concat(
      content_tag("fb:if-section-not-added", capture(&block), :section => section),
      block.binding
    )
  end

  def hide_block_link(id)
    content_tag(:form, hidden_field_tag(:block, id), :id => "#{id}_hide") +
    link_to(fb_i("Hide"), hide_block_user_path(current_user),
      :clickrewriteid   => id,
      :clickrewriteurl  => hide_block_user_url(current_user, :canvas => false),
      :clickrewriteform => "#{id}_hide",
      :clicktohide      => id,
      
      :class  => :hide
    )
  end

  def reference(id, reference_url = nil)
    if Rails.env == "development"
      controller.send(:render_to_string, :template => "pages/#{id}", :layout => false)
    else
      fb_ref(
        :url => reference_url || url_for(
          :controller => "pages",
          :action     => "show",
          :id         => id,
          :format     => :fbml,
          :only_path  => false,
          :canvas     => false
        )
      )
    end
  end

  def fb_profile_url(user)
    "http://www.facebook.com/profile.php?id=#{user.facebook_id}"
  end


  def title(text)
    fb_title(text) + content_tag(:h1, text, :class => :title)
  end

  def fb_i(*args, &block)
    options = args.extract_options!
    tag = content_tag("fb:intl", block_given? ? capture(&block): args.shift, options)

    if block_given?
      concat(tag, block.binding)
    else
      return tag
    end
  end

  def fb_it(name, *args, &block)
    options = args.extract_options!.merge(:name => name)
    tag = content_tag("fb:intl-token", block_given? ? capture(&block): args.shift, options)

    if block_given?
      concat(tag, block.binding)
    else
      return tag
    end
  end
end
