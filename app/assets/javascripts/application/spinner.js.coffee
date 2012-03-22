this.Spinner = new class
  x: -1
  y: -1
  enabled : true

  setup: ()->
    @x = -1
    @y = -1
    @enabled = true
    @element = $('#spinner')

    # Tracking mouse
    $('body').mousemove(@.onMouseMove)

  show: (speed, text)->
    return unless @enabled

    # Customizing text label
    custom_text = @element.find('.text .custom')
    default_text = @element.find('.text .default')

    if text
      custom_text.html(text).show()
      default_text.hide()
    else
      default_text.show()
      custom_text.hide()

    @.moveToPosition()

    @element.fadeIn(speed)

  hide: (speed)->
    @element.fadeOut(speed)

  blink: (speed, delay)->
    return unless @enabled

    @.moveToPosition()

    @element.fadeIn(speed).delay(delay).fadeOut(speed)

  storePosition: (x, y)->
    @x = x
    @y = y

  moveToPosition: ()->
    if @x > -1 && @y > -1
      @element.css(
        top: @y - @element.height() / 2
      )

  alignTo: (selector)->
    position = $(selector).offset()

    @.storePosition(position.left, position.top)


  # Events

  onFormSubmit: ()=>
    @.show()

  onAjaxStart: ()=>
    @.show()

  onAjaxStop: ()=>
    @.show()

  onMouseMove: (e)=>
    @.storePosition(e.pageX, e.pageY)
