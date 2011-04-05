module TutorialsHelper
  def t_step(property, step = current_step)
    t("tutorial.steps.#{step}.#{property}")
  end
  
  def step_title(step = current_step)
    t_step("title", step)
  end
  
  def step_text(step = current_step)
    t_step("text", step)
  end
  
  def final_step?(step = current_step)
    Tutorial::STEPS.last == step
  end
  
  def step_index(step = current_step)
    Tutorial::STEPS.index(step)
  end
  
  def next_step(step = current_step)
    final_step?(step) ? "" : Tutorial::STEPS[step_index(step) + 1] 
  end
  
  def current_step
    if (current_step = current_user.tutorial_step).empty?
      current_step = Tutorial::STEPS.first
    end
    current_step.to_sym 
  end
  
  def next_step_button(value = step_button_value)
    button_to_function(escape_javascript(value), 
      :onclick => '$(document).trigger("tutorial.next_step")'
    )
  end
  
  def tutorial_dialog(options = {})
    options[:content] ||= {}
    
    if options.delete(:with_title)
      options[:content][:title] = escape_javascript(t_step("dialog_title"))
    end
    options[:content][:text] = escape_javascript(options[:content][:text] || t_step("dialog_text"))
    
    if options.delete(:with_close_button)
      close_button = escape_javascript(t_step("close_button_value"))
      options[:content][:text] << content_tag(:div, next_step_button(close_button), :class => 'buttons')
    end
    
    "$.showTutorialDialog(#{options.to_json});".html_safe
  end
  
  def tip_on(target, options = {})
    options[:content] ||= escape_javascript(step_text)
    
    options[:position] ||= {}
    
    options[:position][:corner] ||= {}
    options[:position][:corner][:target] ||= 'bottomMiddle'
    options[:position][:corner][:tooltip] ||= 'topMiddle'
    
    if options.delete(:with_close_button)
      close_button_value = escape_javascript(t_step("close_button_value"))
      options[:content] << content_tag(:div, next_step_button(close_button_value), :class => 'buttons')
    end
    
    "$('#{target}').tutorialTip(#{options.to_json});".html_safe
  end
  
  def spot_on(target)
    "$('#{target}').tutorialSpot();".html_safe
  end
  
  def click_trigger(target)
    "$('#{target}').tutorialClickTarget();".html_safe
  end
  
  def make_visible(target)
    "$('#{target}').tutorialVisible();".html_safe
  end
  
  def goto_main_menu_item(item_name, tip_options = {})
    selector = "#main_menu a.#{item_name}"
    result = ""
    result << tip_on(selector, tip_options)
    result << spot_on(selector)
    result << click_trigger(selector)
    result.html_safe
  end
  
  def step(step_name, options = {}, &block)
    if current_step == step_name
      
      step_actions = capture(&block)
      
      dom_ready("$(document).unbind('tutorial.show');")
      dom_ready("$(document).bind('tutorial.show', function() { #{step_actions} });")
      
      if options.include?(:dont_control_upgrade)
        dom_ready("$(document).trigger('tutorial.show');")
      else
        dom_ready("tutorialAllowUpdradeDialog();")
      end
      
    end
  end
  
end