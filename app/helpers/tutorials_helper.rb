module TutorialsHelper
  def tutorial_step(controller, action, completed)
    current = (controller_name == controller && action_name == action)
    
    yield(current, completed)
  end
end
