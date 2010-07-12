module Admin::BaseHelper
  def admin_state(object)
    content_tag(:span, object.state.to_s.capitalize, :class => object.state)
  end

  def admin_title(value, doc_url = nil)
    @admin_title = value

    title = content_tag(:h1, value)

    if doc_url.present?
      title << link_to(t("admin.documentation"), "http://railorz.com/help/#{doc_url}",
        :target => :_blank,
        :class  => :documentation
      )
    end

    content_tag(:div, title, :class => :title)
  end
end