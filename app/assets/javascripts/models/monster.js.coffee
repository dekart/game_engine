window.Monster = class extends Spine.Model
  @configure 'Monster', 'id', 'hp', 'monster_type', 'time_remaining'

  fighting: ()->
    this.hp > 0 && this.time_remaining > 0

  healthPercentage: ->
    @.hp / @.monster_type.health * 100