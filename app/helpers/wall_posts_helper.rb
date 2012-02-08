require 'will_paginate'

module WallPostsHelper
  class PaginationRenderer < WillPaginate::ViewHelpers::LinkRenderer
    def page_link(page, text, attributes = {})
      attributes[:remote] = true
      
      @template.link_to(text,
        @template.send(:character_wall_posts_path, @collection.first.character, :page => page),
        attributes
      )
    end
  end
end
