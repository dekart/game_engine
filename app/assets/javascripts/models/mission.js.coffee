window.Mission = class extends Spine.Model
  @configure 'Mission', 'key', 'name', 'description', 'button_label', 'success_text', 'failure_text', 'complete_text', 'pictures', 'repeatable', 'level'

  @set: (missions)->
    @refresh(missions, clear: true)

  perform: ->
    $.ajax("/missions/#{ @.id }",
      type: 'PUT'
      success: @.onPerformed
    )

  onPerformed: (response)=>
    @trigger('performed', response)
