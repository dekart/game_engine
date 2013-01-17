window.DesignHelper =
  progressBar: (percentage, label)->
    result = if label then """<div class="text">#{ label }</div>""" else ''

    result += """
      <div class="progress_bar">
        <div
          class="percentage #{ if percentage >= 100 then 'complete' else ''}"
          style="width: #{ if percentage <= 100 then percentage else 100 }%"
        ></div>
      </div>
    """

    @safe result

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

