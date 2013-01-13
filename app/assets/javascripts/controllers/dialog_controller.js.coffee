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
    @.unbindEventListeners()

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
    @el.fadeTo(400, 1)

  close: ->
    @.unbindEventListeners()

    @overlay.detach()
    @el.data('positioned', false).detach()

    $(document).trigger('close.dialog')

  render: ->
    @.updateContent(@content)

  updateContent: (content)->
    @html(
      @.renderTemplate('dialog', content: content)
    )

    @.updateOffset()

  onCloseClick: (e)=>
    e.preventDefault()
    e.stopPropagation()

    @.close()

  updateOffset: ->
    unless @el.data('positioned')
      left = $('#content').offset().left + ($('#content').width() - @el.outerWidth(true)) / 2

      existing_offset = $('#content .dialog').not(@el).offset()

      if existing_offset
        top = existing_offset.top
      else
        top = mouse.y - @el.outerHeight() / 2

    dialog_height = @el.outerHeight(true)
    content_height = $('#content').outerHeight(true)

    if top < 0
      top = $('#content').offset().top + 100
    else if top + dialog_height > content_height - 100
      top = content_height - dialog_height - 100

    @el.css(top: top, left: left).data('positioned', true)
