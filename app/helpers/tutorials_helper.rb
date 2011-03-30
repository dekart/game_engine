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
    current_step = options[:step] || current_step
    options[:title] ||= escape_javascript(t_step("window_title", current_step))
    options[:text] ||= escape_javascript(t_step("window_text", current_step))
    options[:button_name] ||= escape_javascript(t_step("window_button_name", current_step))
    
    dom_ready("$.showTutorialStandardDialog('#{options[:title]}', '#{options[:text]}', '#{options[:button_name]}');")
  end
  
end