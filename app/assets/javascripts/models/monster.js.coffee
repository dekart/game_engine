window.Monster = class extends Spine.Model
  @configure 'Monster', 'id', 'hp', 'monster', 'time_remaining'

  fighting: ()->
    this.hp > 0 && this.time_remaining > 0