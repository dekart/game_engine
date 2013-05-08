class PageList
  constructor: (@element, @options)->
    @item_list = @element.children('ul')
    @items = @item_list.children('li')

    @arrow_left = $('<div class="arrow left"></div>').appendTo(@element).height(@.maxItemHeight())
    @arrow_right = $('<div class="arrow right"></div>').appendTo(@element).height(@.maxItemHeight())

    @item_list.css(@.itemListDimensions())
    @element.css(@.listElementDimensions())

    @.setupStartingPage()

    @.updateArrowAvailability()

    @.setupEventListeners()

  setupEventListeners: ->
    @element.on('click', '.arrow:not(.disabled)', @.onArrowClick)

  setupStartingPage: ->
    @.setCurrentPage(
      Math.floor(
        @items.index(@items.filter('.current').eq(0)) / @.itemsPerPage()
      )
    )

    @item_list.css(@.pageOffset(@current_page))
    @items.css(opacity: 0)
    @.itemsOnPage(@current_page).css(opacity: 1)

  onArrowClick: (e)=>
    e.preventDefault()

    arrow = $(e.currentTarget)

    if arrow.hasClass('left')
      @.switchLeft()
    else
      @.switchRight()

  setCurrentPage: (page)->
    @current_page = page

    if @current_page < 0
      @current_page = 0
    else if @current_page > @.totalPages() - 1
      @current_page = @.totalPages() - 1

  switchLeft: ->
    @.setCurrentPage(@current_page - 1)

    @.itemsOnPage(@current_page).animate(opacity: 1)
    @.itemsOnPage(@current_page + 1).animate(opacity: 0)

    @item_list.stop(false, true).animate(@.pageOffset(@current_page), ()=>
      @.updateArrowAvailability()
    )

  switchRight: ->
    @.setCurrentPage(@current_page + 1)

    @.itemsOnPage(@current_page).animate(opacity: 1)
    @.itemsOnPage(@current_page - 1).animate(opacity: 0)

    @item_list.stop(false, true).animate(@.pageOffset(@current_page), ()=>
      @.updateArrowAvailability()
    )

  itemsPerPage: ->
    @items_per_page ?= Math.floor(
      (@element.width() - @arrow_left.width() - @arrow_right.width()) / @.maxItemWidth()
    )

  totalPages: ->
    Math.ceil(@items.length / @.itemsPerPage())

  itemsOnPage: (page)->
    @items.slice(page * @.itemsPerPage(), (page + 1) * @.itemsPerPage())

  pageOffset: (page)->
    {
      marginLeft: - page * @.maxItemWidth() * @.itemsPerPage()
    }

  updateArrowAvailability: ->
    @arrow_left.toggleClass('disabled', @current_page == 0)
    @arrow_right.toggleClass('disabled', @current_page == (@.totalPages() - 1))

  itemListDimensions: ->
    {
      width: @.totalListWidth()
      height: @.maxItemHeight()
    }

  listElementDimensions: ->
    {
      height: @item_list.outerHeight(true)
    }

  totalListWidth: ->
    @total_list_width ?= _.reduce(
      @items
      (sum, i)->
        sum + $(i).outerWidth(true)
      0
    )

  maxItemHeight: ->
    @max_item_heigth ?= _.max(
      _.map(@items, (i)-> $(i).outerHeight(true) )
    )

  maxItemWidth: ->
    @max_item_width ?= _.max(
      _.map(@items, (i)-> $(i).outerWidth(true) )
    )


(
  ($)->
    $.fn.pageList = (options)->
      controller = $(@).data('page-list-controller')

      unless controller
        controller = new PageList($(@), options)

        $(@).data('page-list-controller', controller)

      controller

)(jQuery)