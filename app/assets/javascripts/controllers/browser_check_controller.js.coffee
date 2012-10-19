window.BrowserCheckController = class extends Spine.Controller
  el: '#browser_check'

  elements:
    '.text' : 'text'

  constructor: ->
    super

    browser = BrowserDetect.browser.toLowerCase()
    version = BrowserDetect.version

    if (browser == "firefox"  and version < 12) or # 10
       (browser == "chrome" and version < 23) or # 20
       (browser == "opera" and version < 12) or # 10
       (browser == "explorer" and version < 9) # 9
      info = I18n.t('browser_check.' + browser)
      selector = "#" + browser
      
    if info
      @.render(info, selector)
    else
      @.hide()

  render: (info, selector)->
    @text.html(info)
    $(selector).show()

  hide: ()->
    @el.hide()
