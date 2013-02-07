window.MonstersHelper =
  completed: (fight)->
    @safe @.renderTemplate("monsters/completed", fight: fight)

  current: (fight)->
    @safe @.renderTemplate("monsters/current", fight: fight)

  available: (type, locked)->
    result = JST["views/monsters/available"](_.extend({type: type, locked: locked}, RewardHelper, RequirementHelper))

    @safe result

  monster_info: (fight)->
    result = JST["views/monster/#{monster.state}"](
      _.extend({monster: monster, fight: fight}, MonstersHelper, RewardHelper)
    )

    @safe result
