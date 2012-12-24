#= require controllers/base_controller

window.MonsterController = class extends BaseController
  el: "#content_wrapper"

  constructor: ->
    super

    @.setupEventListeners()

  setupEventListeners: ->

  show: (id)->
    @loading = true

    $.getJSON("/monsters/#{id}", @.onDataLoad)

  onDataLoad: (response)=>
    @loading = false

    @monster = response.monster
    @fight   = response.fight

    @.render()

  render: ()->
    @html(
      @.renderTemplate("monster/monster", @)
    )
