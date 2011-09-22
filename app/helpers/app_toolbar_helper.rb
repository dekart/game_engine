module AppToolbarHelper
  AVAILABLE_TOOLBARS = %w{applifier}
  
  def app_toolbar
    toolbar = Setting.s(:app_toolbar)

    if AVAILABLE_TOOLBARS.include?(toolbar) && (current_character.level >= Setting.i(:app_toolbar_minimum_level))
      content_tag(:div, render("layouts/toolbars/#{ toolbar }"), :id => :app_toolbar)
    end
  end
end