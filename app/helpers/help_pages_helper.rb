module HelpPagesHelper
  def help_link(page_alias, text = nil)
    if HelpPage.visible?(page_alias) or current_user.try(:admin?)
      link_to(text || '&nbsp;'.html_safe, help_page_path(page_alias), :class => :help)
    end
  end
end
