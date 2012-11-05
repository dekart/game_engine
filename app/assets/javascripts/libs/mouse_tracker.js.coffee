window.MouseTracker = class
  constructor: ->
    @x = -1
    @y = -1

    # Tracking mouse
    $('body').mousemove(@.onMouseMove)

  onMouseMove: (e)=>
    @.storePosition(e.pageX, e.pageY)

  storePosition: (x, y)->
    @x = x
    @y = y

  isTracked: ->
    @x > -1 && @y > -1