module HelpPagesHelper
  def help_link(page_alias, text = nil)
    if HelpPage.visible?(page_alias) or current_user.admin?
      link_to_function(text || asset_image_tag("icons_help"), "$.dialog({ajax: '#{help_page_path(page_alias)}'})")
    end
  end
end
