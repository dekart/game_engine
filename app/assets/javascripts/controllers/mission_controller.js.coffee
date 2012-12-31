#= require ./base_controller

window.MissionController = class extends BaseController
  @show: ()->
    @controller ?= new @()
    @controller.show()

  className: 'missions'

  prepareHelpers: ->
    super

    _.extend(@helpers, MissionHelper)

  setupEventListeners: ->
    @el.on('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    @el.on('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    Mission.bind('performed', @.onDataMissionPerform)

  unbindEventListeners: ->
    @el.off('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    @el.off('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

  show: ()->
    @loading = true

    $.getJSON('/mission_groups', @.onDataLoad)

    @.render()

  render: ->
    @.unbindEventListeners()

    @html(
      @.renderTemplate('missions/list', @)
    )

    $('#page').empty().append(@el)

    @el.find('#mission_group_list').pageList()

    @.setupEventListeners()

  onDataLoad: (response)=>
    @loading = false

    MissionGroup.set(response.groups)
    Mission.set(response.missions)

    @.render()

  onDataMissionPerform: (mission, response)=>
    MissionResultDialogController.show(response)

    @.render()

  onClientMissionGroupClick: (e)=>
    target = $(e.currentTarget)

    unless target.hasClass('current')
      Mission.find(parseInt(target.data('group-id'), 10)).perform()

  onClientMissionButtonClick: (e)=>
    Mission.find(parseInt($(e.currentTarget).data('mission-id'), 10)).perform()
