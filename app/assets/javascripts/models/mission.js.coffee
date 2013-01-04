window.Mission = class extends Spine.Model
  @configure 'Mission', 'key', 'name', 'description', 'button_label', 'success_text', 'failure_text', 'complete_text', 'pictures', 'repeatable', 'level'

  @set: (missions)->
    @refresh(missions, clear: true)

  perform: ->
    $.ajax("/missions/#{ @.id }.json",
      type: 'PUT'
      success: @.onPerformed
    )

  onPerformed: (response)=>
    @updateAttributes(response.mission)

    @trigger('performed', response)

  isPerformable: ->
    0 <= @.level.progress < @.level.steps or @.repeatable

  isJustComplete: ->
    @.level.position > 0 and @.level.progress == 0 or
    @.level.progress == @.level.steps

  buttonLabel: ->
    if @.button_label
      @.button_label
    else if @.level.progress == 0
      I18n.t('missions.buttons.start')
    else
      I18n.t('missions.buttons.continue')
