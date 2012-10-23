window.BrowserCheckController = class extends Spine.Controller

  el: '#browser_check'

  constructor: ->
    super

    browser = BrowserDetect.browser.toLowerCase()
    version = BrowserDetect.version

    if (browser == "firefox"  and version < 12) or # 10
       (browser == "chrome" and version < 23) or # 20
       (browser == "opera" and version < 12) or # 10
       (browser == "explorer" and version < 9) # 9
      @el.show()
      @.render(browser)

  render: (selector)->
    @html(
      @.renderTemplate(selector)
    )

  renderTemplate: (path)->
    JST["views/browsers/#{path}"](@)
