window.BrowserCheckController = class extends Spine.Controller
  el: '#browser_check'

  elements:
    '.text' : 'text'

  constructor: ->
    super

    # check browser, then hide block or show text
    switch BrowserDetect.browser
      when "Firefox"
        if BrowserDetect.version < 11 # right - 10
          info = "Update your browser: " + BrowserDetect.browser + ", " + BrowserDetect.version
      when "Chrome"
        if BrowserDetect.version < 21 # right - 18
          info = "Update your browser: " + BrowserDetect.browser + ", " + BrowserDetect.version
      when "Opera"
        if BrowserDetect.version < 12 # right - 11
          info = "Update your browser or install another one: " + BrowserDetect.browser + ", " + BrowserDetect.version
      when "Explorer"
        if BrowserDetect.version < 9 # right - 9
          info = "Install another browser or update yours: " + BrowserDetect.browser + ", " + BrowserDetect.version

    if info
      @.render(info)
    else
      @.hide()

  render: (info)->
    @text.text(info)

  hide: ()->
    @el.hide()
