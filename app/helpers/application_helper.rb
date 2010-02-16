# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def hide_block_link(id)
    link_to_remote(t("blocks.hide"),
      :url    => hide_block_user_path(current_user, :block => id),
      :before => "$('##{id}').hide()",
      :html   => {:class => :hide}
    )
  end
  safe_helper :hide_block_link

  def title(text)
    content_tag(:h1, text, :class => :title)
  end
  safe_helper :title

  def icon(name)
    image_tag("icons/#{name}.gif", :alt => name.to_s.titleize)
  end

  def admin_only(&block)
    if current_user && current_user.admin?
      concat(capture(&block))
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

  def attack(value, tag = :div)
    content_tag(tag, value, :class => :attack) if value.to_i > 0
  end

  def defence(value, tag = :div)
    content_tag(tag, value, :class => :defence) if value.to_i > 0
  end

  def collection(*args, &block)
    options = args.extract_options!

    items = args.shift
    has_elements = args.shift || items.any?

    if has_elements
      yield(items)
    elsif options[:empty_set] != false
      concat(
        empty_set(options[:empty_set])
      )
    end
  end

  def empty_set(*args)
    options = args.extract_options!
    label = args.first

    content_tag(:div, label || t(".empty_set", :default => t("common.empty_set")), options.reverse_merge(:class => :empty_set))
  end

  def amount_select_tag
    select_tag(:amount, options_for_select((1..10).to_a))
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
        {:class => :progress_bar}.merge(options)
      )
    end
  end
  safe_helper :percentage_bar

  def dom_ready(&block)
    @dom_ready ||= []
    
    if block_given?
      @dom_ready << capture(&block)
    else
      javascript_tag("$(function(){ #{ @dom_ready.join("\n") } });")
    end
  end

  def google_analytics
    if Configuration[:app_google_analytics_id].present?
      %{
        <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{ Configuration[:app_google_analytics_id] }']);
          _gaq.push(['_trackPageview']);

          (function() {
            var ga = document.createElement('script');
            ga.src = 'http://www.google-analytics.com/ga.js';
            ga.setAttribute('async', 'true');
            document.documentElement.firstChild.appendChild(ga);
          })();
        </script>
      }.html_safe!
    end
  end

  def result_for(type, &block)
    concat(
      content_tag(:div, capture(&block), :id => "#{type}_result", :class => :result_content)
    )
  end
end
