class Timer
  tick_length: 1000

  constructor: (args...)->
    [@finish_callback, @tick_callback] = args

  start: (countdown)->
    @.stop()

    return if countdown <= 0

    @last_tick = (new Date()).valueOf()
    @finish_at = @last_tick + countdown * 1000

    @ticker = setInterval(
      ()=> @.checkTick()
      10
    )

  stop: ()->
    if @ticker
      clearInterval(@ticker)

      @ticker = null

  secondsToFinish: ()->
    Math.round(
      (@finish_at - (new Date()).valueOf()) / 1000
    )

  checkTick: ()->
    if (new Date()).valueOf() - @last_tick >= @.tick_length
      @last_tick += @.tick_length

      @.onTick()

      if @last_tick >= @finish_at
        @.stop()

        @.onFinish()

  onTick: ()->
    @tick_callback?(@)

  onFinish: ()->
    @finish_callback?(@)




window.Timer = Timer