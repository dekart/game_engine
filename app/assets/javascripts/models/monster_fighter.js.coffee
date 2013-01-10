window.MonsterFighter = class extends Spine.Model
  @configure 'MonsterFighter', 'facebook_id', 'damage'

  @find_by_facebook_id: (facebook_id)->
    @select (fighter)-> fighter.facebook_id == facebook_id

  @update: (fighters)->
    old_fighters = @all()

    for fighter in fighters
      if old_fighter = @find_by_facebook_id(fighter[0])[0]
        index = old_fighters.indexOf(old_fighter)
        old_fighters.splice(index, 1)

        old_fighter.updateAttributes(damage: fighter[1])
      else
        @create(
          facebook_id: fighter[0],
          damage: fighter[1]
        )

    for fighter in old_fighters
      fighter.destroy()

    while @all().length > 12
      @first().destroy()

    @all()

  @populate: (fighters)->
    for fighter in fighters
      @create(
        facebook_id: fighter[0],
        damage: fighter[1]
      )

    @all()

  @coords: ()->
    [
      [62, 20], [175, 77], [118, 190], [ 5, 133],
      [ 5, 77], [118, 20], [175, 133], [62, 190],
      [ 5, 20], [175, 20], [175, 190], [ 5, 190]
    ]

  image_url: ()->
    "https://graph.facebook.com/#{this.facebook_id}/picture?type=square&return_ssl_resources=1"