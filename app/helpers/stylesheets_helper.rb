module StylesheetsHelper
  def editable_stylesheet_link
    style = params[:try_stylesheet] ? Stylesheet.find(params[:try_stylesheet]) : Stylesheet.find_by_current(true)

    if Rails.env.development?
      content_tag(:style, 
        format_stylesheet_content(style ? style.content : File.read(default_stylesheet_path))
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
        stylesheet_link_tag("default.css?#{File.mtime(default_stylesheet_path)}")
      end
    end
  end

  def format_stylesheet_content(content)
    content.gsub!(/url\(([^)]+)\)/) do |match|
      match.replace "url(#{image_path($1)})"
    end

    content
  end

  def default_stylesheet_path
    File.join(RAILS_ROOT, "app", "views", "stylesheets", "default.css")
  end
end
