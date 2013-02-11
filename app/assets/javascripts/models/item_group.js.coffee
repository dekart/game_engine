window.ItemGroup = class extends Spine.Model
  @configure 'ItemGroup', 'key', 'name', 'current'

  @set: (groups)->
    @refresh(groups, clear: true)

  @current: ->
    @findByAttribute('current', true)
