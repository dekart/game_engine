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
    Tutorial.final_step?(step)
  end
  
  def step_index(step = current_step)
    Tutorial.step_index(step)
  end
  
  def next_step(step = current_step)
    Tutorial.next_step(step) 
  end
  
  def current_step
    if (step = current_user.tutorial_step).empty?
      step = Tutorial::STEPS.first
    end
    step.to_sym 
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
  
  def javascript_for_next_step_trigger()
    if final_step?
      func_options = {
        :url => toggle_block_user_path(current_user, :block => 'tutorial'),
        :before => "tutorialHide()"
      }
    else
      func_options = {
        :url => update_step_tutorials_path,
        :method => :put,
        :update => :tutorial,
        :with => "'tutorial_step=#{next_step}'"
      }
    end
    remote_function(func_options)
  end
  
  def step(step_name, options = {}, &block)
    if current_step == step_name
      
      step_actions = capture(&block)
      
      if options[:ajax]
        dom_ready("bindTutorialTrigger(function() { #{javascript_for_next_step_trigger} } );") 
      end
      
      dom_ready("$(document).unbind('tutorial.show').bind('tutorial.show', function() { #{step_actions};" <<
          "if ($('.tutorialScrollTarget').is(':visible')) $.scrollTo('.tutorialScrollTarget'); " <<
        "});")
      
      if options.include?(:dont_control_upgrade)
        dom_ready("$(document).trigger('tutorial.show');")
      else
        dom_ready("tutorialAllowUpdradeDialog();")
      end
      
      flash[:show_tutorial] = true
    end
  end
  
  def resolve_tutorial_changes
    if !current_user.tutorial_step.empty? && !flash[:tutorial_step_updated]
      # update on non-ajax tutorial step
      current_user.update_attribute(:tutorial_step, Tutorial.next_step(current_user.tutorial_step))
    end
    
    # if flash[:show_tutorial] 
    # else
    #   Rails.logger.debug("Disable tutorial")
    #   # user exit game on some tutorial step and now returns. we don't show tutorial
    #   current_user.update_attribute(:show_tutorial, false)
    # end
  end
  
end