window.BrowserCheckController = class extends Spine.Controller
  el: '#browser_check'

  elements:
    '.text' : 'text'

  constructor: ->
    super

    # check browser, then hide block or show text
    info = BrowserDetect.browser + ", " + BrowserDetect.version + ", " + BrowserDetect.OS;

    @.render(info)

  render: (info)->
    @text.text(info)

  hide: ()->
    @el.hide()
