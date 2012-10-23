window.BrowserCheckController = class extends Spine.Controller

  el: '#browser_check'

  constructor: ->
    super

    @.setupEventListeners()

    browser = BrowserDetect.browser.toLowerCase()
    version = BrowserDetect.version

    if (browser == "firefox"  and version < 10) or
       (browser == "chrome" and version < 20) or
       (browser == "opera" and version < 10) or
       (browser == "explorer" and version < 9)
      @.render(browser)

  setupEventListeners: ->
    @el.on('click', '.hide', @.onHideClick)

  onHideClick: (e)=>
    $.get("/users/toggle_block?block=browser_check", (response)=>
      @el.hide()
    )

  render: (browser)->
    @html(
      JST["views/browser_check/#{ browser }"](@)
    )
    @el.show()
