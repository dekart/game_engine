module Admin::BaseHelper
  def admin_flash_block(*args, &block)
    options = args.extract_options!
    display_keys = args.any? ? args : [:success, :error, :notice]

    result = ""

    display_keys.each do |key|
      unless flash[key].blank?
        value = block_given? ? capture(flash[key], &block) : flash[key]

        flash.discard(key)

        result << content_tag(:div, value,
          options.reverse_merge(:id => :flash, :class => key)
        )
      end
    end

    block_given? ? concat(result.html_safe) : result.html_safe
  end

  def admin_state(object, options = {})
    options = options.reverse_merge(
      :controls => true,
      :exclude  => [],
      :confirm  => [:deleted]
    )
    
    result = [
      content_tag(:span, object.state.to_s.titleize, :class => object.state)
    ]
    
    if options[:controls]
      object.class.state_machine(:state).states.each do |state|
        next if (state.name == object.state.to_sym) || options[:exclude].include?(state.name)
        
        link_options = {
          :url    => polymorphic_url([:change_state, :admin, object], :state => state.name),
          :method => :put
        }
        
        if options[:confirm].include?(state.name)
          link_options[:confirm] = t('admin.change_state.confirm', 
            :object_name  => object.class.human_name, 
            :state        => state.name.to_s.titleize
          )
        end
          
        result.push link_to_remote(state.name.to_s.titleize, link_options) 
      end
    end
    
    result.join(' ').html_safe
  end

  def admin_position_controls(object)
    controls = []
    
    unless object.first?
      controls << link_to_remote(t('admin.change_position.move_higher'),
        :url    => polymorphic_url([:change_position, :admin, object], :direction => :up),
        :method => :put,
        :html   => {:class => 'move_higher'}
      )
    end

    unless object.last?
      controls << link_to_remote(t('admin.change_position.move_lower'),
        :url    => polymorphic_url([:change_position, :admin, object], :direction => :down),
        :method => :put,
        :html   => {:class => 'move_lower'}
      )
    end
    
    content_tag(:div, controls.join(' ').html_safe, :id => dom_id(object, :position_controls))
  end
  
  def admin_title(value, doc_topic = nil)
    @admin_title = value

    label = [
      value,
      (admin_documentation_link(doc_topic) unless doc_topic.blank?)
    ].compact.join(" ").html_safe

    content_tag(:h1, label, :class => :title)
  end

  def admin_documentation_link(topic)
    link_to(t("admin.documentation"), admin_documentation_url(topic),
      :target => :_blank,
      :class  => :documentation
    )
  end

  def admin_documentation_url(topic)
    "http://railorz.com/help/#{topic}"
  end

end