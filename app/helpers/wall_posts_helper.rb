require 'will_paginate'

module WallPostsHelper
  class PaginationRenderer < WillPaginate::ViewHelpers::LinkRenderer
     def link(text, target, attributes = {})
      attributes[:remote] = true
      
      if target.is_a? Fixnum
        attributes[:rel] = rel_value(target)
        target = @template.send(:character_wall_posts_path, @collection.first.character, :page => target)
      end
      attributes[:href] = target
      
      @template.link_to(text.to_s.html_safe, target, attributes)
    end
  end
end
