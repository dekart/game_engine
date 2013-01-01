class List
  constructor: (@element, @options)->
    @item_list = @element.children('ul')
    @items = @item_list.children('li')

    @item_list.css(@.itemListDimensions())

    if @.isScrollable()
      @scroller = @.createScroller()

      @slider = @scroller.find('.slider').slider(
        _.extend(@.sliderOptions(),
          slide: @.onSlide
        )
      )

      @element.css(@.listElementDimensions())

      @element.on('mousewheel', @.onScroll)

  onSlide: (event, ui)=>
    @.scrollTo(ui.value)

  onScroll: (e, new_value)=>
    e.preventDefault()

    unless @slider.slider('value') == new_value
      @slider.slider('value', new_value)

      @.scrollTo(new_value)

  scrollSpeed: (delta)->
    # Limiting maximum scroll speed to an opinion-based magic number
    if delta < -0.105
      speed = -0.105
    else if delta > 0.105
      speed = 0.105
    else
      speed = delta

    Math.round(@.sliderStep() * speed)

  maxItemHeight: ->
    @max_item_heigth ?= _.max(
      _.map(@items, (i)-> $(i).outerHeight(true) )
    )

  maxItemWidth: ->
    @max_item_width ?= _.max(
      _.map(@items, (i)-> $(i).outerWidth(true) )
    )

  createScroller: ->
    $('<div class="scroller"><div class="slider"></div>')

  scrollTo: (value)->
    throw 'Should be re-defined'

  sliderRange: ->
    throw 'Should be re-defined'

  sliderStep: ->
    throw 'Should be re-defined'

  itemListDimensions: ->
    throw 'Should be re-defined'

  listElementDimensions: ->
    throw 'Should be re-defined'

  isScrollable: ->
    throw 'Should be re-defined'


class HorizontalList extends List
  createScroller: ->
    super.appendTo(@element)

  onScroll: (e, delta, deltaX, deltaY)=>
    range = @slider.slider('option', 'max')

    new_value = @slider.slider('value') - @.scrollSpeed(delta)

    if new_value < 0
      new_value = 0
    else if new_value > range
      new_value = range

    super(e, new_value)

  sliderOptions: ->
    {
      orientation: 'horizontal'
      min: 0
      max: @.sliderRange()
    }

  listElementDimensions: ->
    {
      height: @item_list.outerHeight(true) + @scroller.outerHeight(true)
    }

  itemListDimensions: ->
    {
      width: @.totalListWidth()
      height: @.maxItemHeight()
    }

  totalListWidth: ->
    @total_list_width ?= _.reduce(
      @items
      (sum, i)->
        sum + $(i).outerWidth(true)
      0
    )

  sliderRange: ->
    @.totalListWidth() - @element.innerWidth()

  sliderStep: ->
    @.maxItemWidth()

  isScrollable: ->
    @item_list.outerWidth(true) > @element.innerWidth()

  scrollTo: (value)->
    @item_list.css(marginLeft: -value)

class VerticalList extends List
  orientation: 'vertical'

  createScroller: ->
    super.prependTo(@element)

  onScroll: (e, delta, deltaX, deltaY)=>
    range = @slider.slider('option', 'min')

    new_value = @slider.slider('value') + @.scrollSpeed(delta)

    if new_value < range
      new_value = range
    else if new_value > 0
      new_value = 0

    super(e, new_value)

  sliderOptions: ->
    {
      orientation: 'vertical'
      min: - @.sliderRange()
      max: 0
    }

  listElementDimensions: ->
    {
      width: @item_list.outerWidth(true) + @scroller.outerWidth(true)
    }

  itemListDimensions: ->
    {
      width: @.maxItemWidth()
      height: @.totalListHeight()
    }

  totalListHeight: ->
    @total_list_height ?= _.reduce(
      @items
      (sum, i)->
        sum + $(i).outerHeight(true)
      0
    )

  sliderRange: ->
    @.totalListHeight() - @element.innerHeight()

  sliderStep: ->
    @.maxItemHeight()

  isScrollable: ->
    @item_list.outerHeight(true) > @element.innerHeight()

  scrollTo: (value)->
    @item_list.css(marginTop: value)

(
  ($)->
    $.fn.horizontalList = (options)->
      controller = $(@).data('list-controller')

      unless controller
        controller = new HorizontalList($(@), options)

        $(@).data('list-controller', controller)

      controller

    $.fn.verticalList = (options)->
      controller = $(@).data('list-controller')

      unless controller
        controller = new VerticalList($(@), options)

        $(@).data('list-controller', controller)

      controller
)(jQuery)