#= require ./base_controller
#= require ./requirement_controller

window.MissionController = class extends BaseController
  @show: ()->
    @controller ?= new @()
    @controller.show()

  className: 'missions'

  helpers: ->
    super(MissionHelper)

  setupEventListeners: ->
    @.unbindEventListeners()

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
    else if response.error == 'unsatisfied_requirements'
      RequirementController.show(response.requirements)

    @.render()

  onDataMissionGroupActivate: (group)=>
    @.render()

  onClientMissionGroupClick: (e)=>
    target = $(e.currentTarget)

    unless target.hasClass('current')
      MissionGroup.find(parseInt(target.data('group-id'), 10)).activate()

  onClientMissionButtonClick: (e)=>
    Mission.find(parseInt($(e.currentTarget).data('mission-id'), 10)).perform()
