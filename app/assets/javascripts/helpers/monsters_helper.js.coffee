window.MonstersHelper =
  completedMonster: (fight)->
    @safe @.renderTemplate("monsters/preview/completed", fight: fight)

  currentMonster: (fight)->
    @safe @.renderTemplate("monsters/preview/current", fight: fight)

  availableMonster: (type, locked)->
    @safe @.renderTemplate("monsters/preview/available", type: type, locked: locked)
