module TutorialsHelper
  def tutorial_step(controller, action)
    current = (controller_name == controller && action_name == action) || (@current_step == "#{controller}-#{action}")

    reload_function = remote_function(
      :url    => tutorial_path("#{controller}-#{action}"),
      :method => :get,
      :update => :tutorial_container
    )

    yield(current, reload_function)
  end
  
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
  
  def show_standard_dialog(options = {})
    options[:step] ||= current_step
    options[:title] ||= escape_javascript(t_step("window_title", current_step))
    options[:text] ||= escape_javascript(t_step("window_text", current_step))
    options[:button_name] ||= escape_javascript(t_step("window_button_name", current_step))
    
    dom_ready("$.showTutorialStandardDialog('#{options[:title]}', '#{options[:text]}', '#{options[:button_name]}');")
  end
  
  def tip_on(target, options = {})
    options[:text] ||= step_text()
    options[:position_corner_target] ||= 'bottomRight'
    options[:position_corner_tooltip] ||= 'topLeft'
    
    tip_options = {
      :content => options[:text],
      :position => {
        :corner => {
          :target => options[:position_corner_target],
          :tooltip => options[:position_corner_tooltip]
        }
      }
    }
    
    dom_ready("$('#{target}').tutorialTip(#{tip_options.to_json});")
  end
  
  def spot_on(target)
    dom_ready("$('#{target}').tutorialSpot();")
  end
  
  def click_on(target)
    dom_ready("$('#{target}').tutorialClickTarget();")
  end
  
  def make_visible(target)
    dom_ready("$('#{target}').tutorialVisible();")
  end
end