module Admin::BaseHelper
  def admin_state(object)
    content_tag(:span, object.state.to_s.capitalize, :class => object.state)
  end

  def admin_title(value, doc_topic = nil)
    @admin_title = value

    content_tag(:h1,
      "%s %s" % [
        value,
        doc_topic.present? ? admin_documentation_link(doc_topic) : ""
      ],
      :class => :title
    )
  end

  def admin_documentation_link(topic)
    link_to(t("admin.documentation"), admin_documentation_url(topic),
      :target => :_blank,
      :class  => :documentation
    )
  end

  def admin_documentation_url(topic)
    "http://railorz.com/help/#{topic}"
  end
end