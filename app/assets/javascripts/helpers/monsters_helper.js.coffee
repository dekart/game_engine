window.MonstersHelper =
  completed: (monster, fight)->
    @safe "completed"

  current: (monster, fight)->
    @safe "current"

  available: (type, locked)->
    result = 
      "<div class='monster clearfix'>\
        <div class='info'>\
          <div class='name'>#{type.name}</div>\
          <div class='description'>#{type.description}</div>\
        </div>\
      </div>"

    @safe result
