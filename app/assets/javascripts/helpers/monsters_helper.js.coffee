window.MonstersHelper =
  completed: (monster, fight)->
    result = JST["views/monsters/completed"](_.extend({monster: monster, fight: fight}, RewardHelper))

    @safe result

  current: (monster, fight)->
    percentage = monster.hp / monster.health * 100
    percentage_text = Math.min [percentage, 100]...

    result = JST["views/monsters/current"](
      _.extend({monster: monster, fight: fight, percentage: percentage, percentage_text: percentage_text}, RewardHelper)
    )

    @safe result

  available: (type, locked)->
    result = JST["views/monsters/available"](_.extend({type: type, locked: locked}, RewardHelper, RequirementHelper))

    @safe result

  monster_info: (monster, fight)->
    percentage = monster.hp / monster.health * 100
    percentage_text = Math.min [percentage, 100]...

    result = JST["views/monster/#{monster.state}"](
      _.extend({monster: monster, fight: fight, percentage: percentage, percentage_text: percentage_text}, MonstersHelper, RewardHelper)
    )

    @safe result
