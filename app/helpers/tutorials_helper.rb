module TutorialsHelper
  
  def t_step(property, step = current_step)
    t("tutorial.steps.#{step}.#{property}", :app => t('app_name'))
  end
  
  def step_title(step = current_step)
    t_step("title", step)
  end
  
  def step_text(step = current_step)
    t_step("text", step)
  end
  
  def final_step?(step = current_step)
    Tutorial.final_step?(step)
  end
  
  def step_index(step = current_step)
    Tutorial.step_index(step)
  end
  
  def next_step(step = current_step)
    Tutorial.next_step(step) 
  end
  
  def current_step
    current_user.tutorial_step.to_sym 
  end
  
  def link_to_next_step_button(value = t_step("close_button_value"), html_options = {})
    html_options[:onclick] ||= '$(document).trigger("close.dialog")'
    html_options[:class] = html_options[:class] ? html_options[:class] + ' button' : 'button'
    
    link_to(button(value), '#', html_options)
  end
  
  def next_step_button(value = t_step("close_button_value"), options = {})
    options[:onclick] ||= '$(document).trigger("close.dialog")' 
    
    button_to_function(value, options)
  end
  
  def append_buttons(options = {})
    if (buttons = options[:buttons])
      
      if buttons.respond_to?(:join)
        buttons = buttons.join
      end
      
      options[:content][:text] ||= ""
      options[:content][:text] << content_tag(:div, buttons.html_safe, :class => 'buttons')
    end
  end
  
  def tutorial_dialog(options = {})
    options[:content] ||= {}
    
    # TODO: clean options
    if options.delete(:with_title)
      options[:content][:title] = t_step("dialog_title")
    end
    options[:content][:text] = options[:content][:text] || t_step("dialog_text")
    
    append_buttons(options)
    
    "Tutorial.showDialog(#{options.to_json});".html_safe
  end
  
  def tip_on(target, options = {})
    options[:content] ||= {}
    options[:content][:text] = options[:content][:text] || step_text
    
    append_buttons(options)
    
    "$('#{target}').tutorial('tip', #{options.to_json});".html_safe
  end
  
  def spot_on(target)
    "$('#{target}').tutorial('spot');".html_safe
  end
  
  def click_trigger(target, options = {})
    options[:redirector_url] = update_step_tutorials_path unless @evented_step
    "$('#{target}').tutorial('clickTarget', #{options.to_json});".html_safe
  end
  
  def make_responsible(target)
    "$('#{target}').tutorial('responsible');".html_safe
  end
  
  def make_visible(target)
    "$('#{target}').tutorial('visible');".html_safe
  end
  
  def goto_main_menu_item(item_name, tip_options = {})
    selector = "#main_menu a.#{item_name}"
    result = ""
    result << tip_on(selector, tip_options)
    result << spot_on(selector)
    result << click_trigger(selector)
    result.html_safe
  end
  
  def javascript_for_next_step_trigger()
    if final_step?
      func_options = {
        :url => toggle_block_user_path(current_user, :block => 'tutorial'),
        :before => "Tutorial.hide()"
      }
    else
      func_options = {
        :url => update_step_tutorials_path,
        :update => :tutorial
      }
    end
    remote_function(func_options)
  end
  
  def step(step_name, options = {}, &block)
    if current_step == step_name
      
      @evented_step = true if options[:change_event]
      options.reverse_merge!(
        :control_upgrade_dialog => true,
        :show_progress => true
      )
      
      @show_progress = options[:show_progress]
      
      step_actions = capture(options, &block)
      
      dom_ready("Tutorial.step(function(){ #{ step_actions } }, #{options.to_json});")
    end
  end
  
  def tutorial_visible?
    current_user.show_tutorial? && flash[:show_tutorial] 
  end
  
end