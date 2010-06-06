module Admin::BaseHelper
  def admin_state(object)
    content_tag(:span, object.state.to_s.capitalize, :class => object.state)
  end

  def admin_title(value)
    @admin_title = value

    content_tag(:h1, value)
  end
end