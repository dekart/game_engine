window.MissionGroup = class extends Spine.Model
  @configure 'MissionGroup', 'key', 'name', 'current', 'requirements'

  @set: (groups)->
    @refresh(groups, clear: true)

  @current: ->
    @findByAttribute('current', true)

  isLocked: ->
    _.some(@.requirements, (r)-> r[3] == false)
