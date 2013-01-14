window.DesignHelper =
  button: (key, klass)->
    @safe "<button class='#{klass}'>#{I18n.t(key)}</button>"

  cost_button: (key, klass, currency, price)->
    @safe "<button class='#{klass}'>#{I18n.t(key)}<span class='cost #{currency}'>#{price}</span></button>"

  publish_button: (text, options)->
    type = options["type"]
    delete options["type"]

    attributes = for key, value of options
      "data-#{key}='#{value}'"

    @safe "<a href='#' data-stream-dialog='#{ type }' #{ attributes.join(' ') } class='publish button'> \
      <span>#{ I18n.t(text) }</span></a>"
