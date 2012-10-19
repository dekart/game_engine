window.BrowserCheckController = class extends Spine.Controller
  el: '#browser_check'

  elements:
    '.text' : 'text'

  constructor: ->
    super

    # check browser and hide #browser_check or show text
    Character.bind('save', @.onDataUpdate)

  render: ()->
    @text.text("browser_info")

  onDataUpdate: =>
    @.render()
