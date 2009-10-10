module StylesheetsHelper
  def editable_stylesheet_link
    if params[:try_stylesheet] and style = Stylesheet.find_by_id(params[:try_stylesheet])
      return content_tag(:style,
        format_stylesheet_content(style.content)
      )
    else
      style = Stylesheet.find_by_current(true)

      if Rails.env.development?
        content_tag(:style,
          format_stylesheet_content(style ? style.content : File.read(Stylesheet::DEFAULT_PATH))
        )
      else
        if style
          stylesheet_link_tag(
            stylesheet_url(style,
              :format     => :css,
              :updated_at => style.updated_at,
              :canvas     => false
            )
          )
        else
          stylesheet_link_tag("default.css?#{File.mtime(Stylesheet::DEFAULT_PATH).to_i}")
        end
      end
    end
  end

  def format_stylesheet_content(content)
    content.gsub!(/url\(([^)]+)\)/) do |match|
      url = $1

      if url =~ /^asset:(.*)/ and asset = Asset.find_by_alias($1)
        url = asset.image.url
      end
      
      match.replace "url(#{image_path(url)})"
    end

    content
  end
end
