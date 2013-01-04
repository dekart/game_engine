window.StreamDialog = class
  @show: (post_options, callback)->
    if_fb_initialized =>
      options = $.extend(true, {}, post_options, {method: 'stream.publish'})

      FB.ui(options, (response)=>
        callback.call(this, response)
      )

      $(document).trigger('facebook.dialog')

  @prepare: (alias, data, callback)->
    $.get("/stories/#{ alias }/prepare.json", data || {}, (response)=>
      @show(response, callback)
    )
