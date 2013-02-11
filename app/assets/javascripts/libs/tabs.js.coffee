class window.TabController
  constructor: (@element, @options)->
    @tab_list = @element.children('ul')
    @tabs = @tab_list.find('li')
    @containers = @element.find('>div.tab_content')

    @.setupEventListeners()

    @.setCurrentTab(@tabs.filter(':not([data-url]):first'))

  setupEventListeners: ->
    @tab_list.on('click', 'li', @.onTabClick)

  onTabClick: (e)=>
    e.preventDefault()

    tab = $(e.currentTarget)

    @.selectTab(e.currentTarget)

  selectTab: (tab)->
    if _.isNumber(tab)
      tab = @tabs.eq(tab)
    else if _.isString(tab)
      tab = @tabs.filter("[data-tab=#{ tab }]")
    else
      tab = $(tab)

    if tab.data('url')
      @.loadTab(tab)
    else
      @.setCurrentTab(tab)

  loadTab: (tab)->
    url = tab.data('url')

    tab.data('url', null) # Remove url to avoid double load

    @.setCurrentTab(tab)

    $.get(url, (response)=>
      container = @.containerFor(tab)

      container.html(response)

      @options.onLoad?(tab, container)
    )

  setCurrentTab: (tab)->
    @tabs.removeClass('selected')
    @containers.hide()

    @current_tab = tab
    @current_container = @.containerFor(tab)

    @current_tab.addClass('selected')

    @current_container.show()

    @element.trigger('select.tab', @)

  containerFor: (tab)->
    @containers.filter("##{ tab.data('tab') }")

  selectedTabId: ->
    @tabs.filter('.selected').data('tab')

(
  ($)->
    $.fn.tabs = (options)->
      controller = $(@).data('tab-controller')

      unless controller
        controller = new TabController($(@), options)

        $(@).data('tab-controller', controller)

      controller
)(jQuery)