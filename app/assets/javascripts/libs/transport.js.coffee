class Transport extends Spine.Module
  @include Spine.Events

  send: (event, data)->
    switch event
      when 'load_monsters'
        @.loadMonsters()
      when 'load_finished_monsters'
        @.loadFinishedMonsters()
      when 'load_monster'
        @.loadMonster(data)
      when 'create_monster'
        @.createMonster(data)
      when 'load_shop'
        @.loadShop(data)
      else
        console?.log('Unknown event type:', event, data)

  loadMonsters: ->
    $.getJSON('/monsters', (response)=>
      @.trigger('monsters_loaded', response)
    )

  loadFinishedMonsters: ->
    $.get("/monsters/finished", (response)=>
      @.trigger('finished_monsters_loaded', response)
    )

  loadMonster: (id)->
    $.get("/monsters/#{ id }", (response)=>
      @.trigger('monster_loaded', response)
    )

  createMonster: (type)->
    $.post("/monsters", {monster_type_id: type}, (response)=>
      @.trigger('monster_loaded', response)
    )

  loadShop: (group_id)->
    $.get((if group_id? then "/item_groups/#{group_id}/items.json" else "/items.json"), (response)=>
      @.trigger('shop_loaded', response)
    )


window.transport = new Transport()