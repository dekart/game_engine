#= require application/timer

class VisualTimer extends window.Timer
  constructor: (args...)->
    [@selector, @finish_callback, @tick_callback] = args

  onTick: ()->
    $(@selector...).html(
      @.formatTime(@.secondsToFinish())
    )

    super

  formatTime: (value)->
    result = ""

    days    = Math.floor(value / 86400)
    hours   = Math.floor((value - days * 86400) / 3600)
    minutes = Math.floor((value - days * 86400 - hours * 3600) / 60)
    seconds = value - days * 86400 - hours * 3600 - minutes * 60

    if days > 0
      result = "#{ I18n.t('client.timer.days', count: days) }, "

    if hours > 0
      result = "#{ result } #{ hours }:"

    if minutes < 10
      result = "#{ result }0#{ minutes }"
    else
      result = "#{ result }#{ minutes }"

    if seconds < 10
      result = "#{ result }:0#{ seconds }"
    else
      result = "#{ result }:#{ seconds }"

    result

window.VisualTimer = VisualTimer