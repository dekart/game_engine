module FacebookHelper
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

  def fb_custom_multi_friend_selector(*args, &block)
    if block_given?
      options = {:showborder => false, :max => 20}.merge(args.extract_options!)

      concat(content_tag("fb:multi-friend-selector", capture(&block), options), block.binding)
    else
      return fb_multi_friend_selector(*args, &block)
    end
  end

  def fb_profile_url(user)
    "http://www.facebook.com/profile.php?id=#{user.facebook_id}"
  end

  def fb_app_page_url
    "http://www.facebook.com/apps/application.php?api_key=#{Facebooker.facebooker_config["api_key"]}"
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
    fb_named_tag("intl-token", name, *args, &block)
  end

  def fb_fa(name, *args, &block)
    fb_named_tag("fbml-attribute", name, *args, &block)
  end

  def fb_tag(name, *args, &block)
    fb_named_tag("tag", name, *args, &block)
  end

  def fb_ta(name, *args, &block)
    fb_named_tag("tag-attribute", name, *args, &block)
  end

  def link_to_feed_dialog(title, template_class, template_name, options = {})
    bundle_id = Facebooker::Rails::Publisher::FacebookTemplate.bundle_id_for_class_and_method(template_class, template_name.to_s)

    link_to_function(title, "Facebook.showFeedDialog(#{bundle_id}, #{options[:template_data].to_json}, '#{options[:body_general]}', #{options[:target_id] || "null"})", options[:html] || {})
  end

  protected

  def fb_named_tag(tag, name, *args, &block)
    options = args.extract_options!.merge(:name => name)
    tag = content_tag("fb:#{tag}", block_given? ? capture(&block): args.shift, options)

    if block_given?
      concat(tag, block.binding)
    else
      return tag
    end
  end
end