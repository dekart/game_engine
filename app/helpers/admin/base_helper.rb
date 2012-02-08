module Admin::BaseHelper
  def admin_flash_block(*args, &block)
    options = args.extract_options!
    display_keys = args.any? ? args : [:success, :error, :notice]

    result = ""

    display_keys.each do |key|
      unless flash[key].blank?
        value = block_given? ? capture(flash[key], &block) : flash[key]

        flash.discard(key)

        result << (
          %{<div #{ tag_options(options.reverse_merge(:id => :flash, :class => key)) }>#{ value }</div>}
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
      span_tag(object.state.to_s.titleize, object.state)
    ]

    if options[:controls]
      object.class.state_machine(:state).states.each do |state|
        next if (state.name == object.state.to_sym) || options[:exclude].include?(state.name)

        link_options = {
          :method => :put,
          :remote => true
        }

        if options[:confirm].include?(state.name)
          link_options[:confirm] = t('admin.change_state.confirm', 
            :object_name  => object.class.model_name.human, 
            :state        => state.name.to_s.titleize
          )
        end

        result.push link_to(state.name.to_s.titleize, 
          polymorphic_url([:change_state, :admin, object], :state => state.name), 
          link_options
        ) 
      end
    end

    result.join(' ').html_safe
  end

  def admin_position_controls(object)
    controls = []

    unless object.first?
      controls << link_to(t('admin.change_position.move_higher'),
        polymorphic_url([:change_position, :admin, object], :direction => :up),
        :remote => true,
        :class => 'move_higher'
      )
    end

    unless object.last?
      controls << link_to(t('admin.change_position.move_lower'),
        polymorphic_url([:change_position, :admin, object], :direction => :down),
        :method => :put,
        :remote => true,
        :class => 'move_lower'
      )
    end

    (
      %{<div id="#{ dom_id(object, :position_controls) }">#{ controls.join(' ') }</div>}
    ).html_safe
  end

  def admin_title(value, doc_topic = nil)
    @admin_title = value

    label = [
      value,
      (admin_documentation_link(doc_topic) unless doc_topic.blank?)
    ].compact.join(" ")

    (
      %{<h1 class="title">#{ label }</h1>}
    ).html_safe
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

  def admin_menu_link(*args)
    name, link, controllers, actions = args

    controllers = Array.wrap(controllers)
    actions = Array.wrap(actions)
    current = (controller_name == name.to_s || (controllers.include?(controller_name))) &&
      (actions.empty? || actions.include?(action_name))

    link_to(t(".#{ name }"), link,
      :class => "item #{ :current if current }"
    )
  end

end