window.MonstersHelper =
  completed: (monster, fight)->
    result = JST["views/monsters/completed"](monster: monster, fight: fight)

    @safe result

  current: (monster, fight)->
    percentage = monster.hp / monster.health * 100
    percentage_text = Math.min [percentage, 100]...

    result = JST["views/monsters/current"](monster: monster, fight: fight, percentage: percentage, percentage_text: percentage_text)

    @safe result

  available: (type, locked)->
    result = JST["views/monsters/available"](type: type, locked: locked)

    @safe result
