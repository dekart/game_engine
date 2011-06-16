module HelpPagesHelper
  def help_link(page_alias, text = nil)
    if HelpPage.visible?(page_alias) or current_user.try(:admin?)
      if text
        link = link_to(text, help_page_path(page_alias), :class => :help)
      else
        link = link_to('&nbsp;'.html_safe, help_page_path(page_alias), 
          :class => :help, 
          :title => t('help_pages.link.title')
        )
      end
      
      block_given? ? yield(link) : link
    end
  end
end
