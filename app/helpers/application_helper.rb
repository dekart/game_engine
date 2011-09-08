# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  MAINTENANCE_SETTINGS_PATH = Rails.root.join("public", "system", "maintenance.yml").to_s
  
  def admin_only(&block)
    if current_user && current_user.admin? || ENV['OFFLINE']
      concat(capture(&block))
    end
  end

  def group_header(text, group_name = :main, &block)
    @group_headers ||= {}

    if @group_headers[group_name] != text
      @group_headers[group_name] = text

      block_given? ? yield(text) : text
    end
  end
  
  def yield_once(group)
    @yield_once ||= {}
    
    if !@yield_once[group] and @yield_once[group] = yield
      @yield_once[group]
    end
  end

  def reset_group_header(group_name)
    @group_headers[group_name] = nil
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

  def amount_select_tag(*args)
    options = args.extract_options!

    values = (1..10).to_a + args
    values.uniq!
    values.sort!

    select_tag(:amount, options_for_select(values, options[:selected]), options.except(:selected))
  end

  def dom_ready(content = nil, options = {}, &block)
    @dom_ready ||= []

    if content || block_given?
      content = capture(&block) unless content 
      options[:prepend] ? @dom_ready.insert(0, content) : @dom_ready << content
      nil
    else
      javascript_tag("$(function(){ #{ @dom_ready.join("\n") } });")
    end
  end

  def flash_block(*args, &block)
    display_keys = args.any? ? args : [:success, :error, :notice]

    result = ""

    display_keys.each do |key|
      unless flash[key].blank?
        result << (block_given? ? capture(key, flash[key], &block) : content_tag(:p, flash[key], :class => key))
      end
    end

    unless result.blank?
      content_for(:result,
        result_for(flash[:class] || :flash, result.html_safe)
      )
    end
  end

  def maintenance_warning
    if File.file?(MAINTENANCE_SETTINGS_PATH)
      settings = YAML.load(File.read(MAINTENANCE_SETTINGS_PATH))

      yield(settings) if settings[:start] > Time.now
    end
  end
  
  # accumulate collection to accumulator_size and then write
  def accumulate(collection, accumulator_size, &block)
    accumulator = []
    
    collection.each_with_index do |element, i|
      accumulator << element
      
      if accumulator.size == accumulator_size || i == collection.size - 1
        concat(capture(accumulator, &block))
        
        accumulator.clear
      end
    end
  end
end
