module AppToolbarHelper
  AVAILABLE_TOOLBARS = %w{applifier appatyze}

  def app_toolbar
    toolbar = Setting.s(:app_toolbar)

    if AVAILABLE_TOOLBARS.include?(toolbar) && (current_character.level >= Setting.i(:app_toolbar_minimum_level))
      (
        %{<div id="app_toolbar">#{ render("layouts/toolbars/#{ toolbar }") }</div>}
      ).html_safe
    end
  end
end