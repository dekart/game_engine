# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def hide_block_link(id)
    content_tag(:form, hidden_field_tag(:block, id), :id => "#{id}_hide") +
    link_to(fb_i(t("blocks.hide")), hide_block_user_path(current_user),
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

  def title(text)
    fb_title(text) + content_tag(:h1, text, :class => :title)
  end

  def icon(name)
    image_tag("icons/#{name}.gif", :alt => name.to_s.titleize)
  end

  def admin_only(&block)
    if in_canvas? && current_user && current_user.admin?
      concat(capture(&block), block.binding)
    end
  end

  def group_header(text, group_name = :main, &block)
    @group_headers ||= {}

    if @group_headers[group_name] != text
      @group_headers[group_name] = text

      if block_given?
        yield(text)
      else
        return text
      end
    end
  end

  def reset_group_header(group_name)
    @group_headers[group_name] = nil
  end

  def flash_block(display_keys = [:success, :error, :notice], &block)
    result = ""

    display_keys.reject!{|key| flash[key].blank? }

    display_keys.each do |key|
      result << content_tag(:div,
        block_given? ? capture(flash[key], &block) : flash[key],
        :id     => :flash,
        :class  => key
      )
    end

    block_given? ? concat(result) : result
  end
end
