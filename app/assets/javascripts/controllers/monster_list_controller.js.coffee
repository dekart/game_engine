#= require controllers/base_controller

window.MonsterListController = class extends BaseController
  @include window.MonstersHelper

  el: "#content_wrapper"

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->
    @el.on('click', '.fight', @.onFightClick)

  show: ->
    @loading = true

    $.getJSON('/monsters', @.onDataLoad)

  onDataLoad: (response)=>
    @loading = false

    @defeated = response.defeated
    @active   = response.active
    @locked   = response.locked
    @monster_types = response.monster_types

    @.render()

  render: ()->
    @html(
      @.renderTemplate("monsters/list", @)
    )
