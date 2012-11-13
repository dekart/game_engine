#= require controllers/base_controller

window.DialogController = class extends BaseController
  @show: (content)->
    @controller ?= new @()
    @controller.show(content)

  @close: ->
    @controller?.close()

  className: 'dialog'

  constructor: ->
    super

    @overlay = $("<div class='dialog_overlay'></div>")

  setupEventListeners: ->
    @el.on('click', '.close', @.onCloseClick)

  unbindEventListeners: ->
    @el.off('click', '.close', @.onCloseClick)

  show: (content)->
    @.setupEventListeners()

    @content = content

    # Element should be in dom before we render any content into it, or content scripts won't work properly
    @el.css(opacity: 0).appendTo('#content')

    @.render()

    @overlay.css(opacity: 0).appendTo('#content').fadeTo(400, 0.7)
    @el.css(@.calculateOffset()).fadeTo(400, 1)

  close: ->
    @.unbindEventListeners()

    @overlay.detach()
    @el.detach()

    $(document).trigger('close.dialog')

  render: ->
    @html(
      @.dialogWrapper(@content)
    )

  dialogWrapper: (content)->
    @.renderTemplate('dialog', content: content)

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