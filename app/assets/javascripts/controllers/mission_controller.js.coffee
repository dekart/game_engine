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

    MissionGroup.bind('activated', @.onDataMissionGroupActivate)
    Mission.bind('performed', @.onDataMissionPerform)

  unbindEventListeners: ->
    @el.off('click', '#mission_group_list .mission_group', @.onClientMissionGroupClick)
    @el.off('click', '.mission button:not(.disabled)', @.onClientMissionButtonClick)

    MissionGroup.unbind('activated', @.onDataMissionGroupActivate)
    Mission.unbind('performed', @.onDataMissionPerform)

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
    if response.success?
      MissionResultDialogController.show(response)
    else if response.error == 'unsatisfied_requirements' and response.requirements[0][1] == 'ep' and response.requirements[0][3] == false
      EnergyRefillDialogController.show()

    @.render()

  onDataMissionGroupActivate: (group)=>
    @.render()

  onClientMissionGroupClick: (e)=>
    target = $(e.currentTarget)

    unless target.hasClass('current')
      MissionGroup.find(parseInt(target.data('group-id'), 10)).activate()

  onClientMissionButtonClick: (e)=>
    Mission.find(parseInt($(e.currentTarget).data('mission-id'), 10)).perform()
