window.DialogController = class extends Spine.Controller
  @show: (content)->
    @controller ?= new @()
    @controller.show(content)

  @close: ->
    @controller?.close()

  className: 'dialog'

  constructor: ->
    super

    @overlay = $("<div class='dialog_overlay'></div>")

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '.close', @.onCloseClick)

  unbindEventListeners: ->
    @el.off('click', '.close', @.onCloseClick)

  show: (content)->
    @content = content

    # Element should be in dom before we render any content into it, or content scripts won't work properly
    @el.css(opacity: 0).appendTo('#content')

    @.render()

    @overlay.css(opacity: 0).appendTo('#content').fadeTo(400, 0.7)
    @el.css(@.calculateOffset()).fadeTo(400, 1)

  close: ->
    @overlay.detach()
    @el.detach()

    $(document).trigger('close.dialog')

  render: ->
    @html(
      @.dialogWrapper(@content)
    )

  dialogWrapper: (content)->
    JST['views/dialog'](content: content)

  onCloseClick: (e)=>
    e.preventDefault()
    e.stopPropagation()

    @.close()

  calculateOffset: ->
    left = ($('#content').width() - @el.outerWidth()) / 2
    top = mouse.y - @el.outerHeight() / 2

    {
      left: left
      top: if top < 0 then $('#content').offset().top + 100 else top
    }