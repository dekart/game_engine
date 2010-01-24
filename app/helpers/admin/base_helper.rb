module Admin::BaseHelper
  def admin_state(object)
    content_tag(:span, object.state.to_s.capitalize, :class => object.state)
  end
end