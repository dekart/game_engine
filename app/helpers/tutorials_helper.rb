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
  
  def step_title(step_name)
    t("tutorial.steps.#{step_name}.title")
  end
  
  def final_step?(step = exract_current_step)
    Tutorial::STEPS.last == step
  end
  
  def step_index(step = exract_current_step)
    Tutorial::STEPS.index(step)
  end
  
  def next_step(step = exract_current_step)
    final_step?(step) ? "" : Tutorial::STEPS[step_index(step) + 1] 
  end
  
  def exract_current_step
    if (current_step = current_user.tutorial_step).empty?
      current_step = Tutorial::STEPS.first
    end
    current_step.to_sym 
  end
  
end