module HelpPagesHelper
  def help_link(page_alias)
    link_to_function(
      asset_image_tag("icons_help"),
      "$.dialog({ajax: '#{help_page_path(page_alias)}'})"
    ) if HelpPage.visible?(page_alias)
  end
end
