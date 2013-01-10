window.Monster = class extends Spine.Model
  @configure 'Monster', 'id', 'name', 'description', 'health', 'hp',
    'image_url', 'stream_image_url', 'time_remaining'

  fighting: ()->
    this.hp > 0 && this.time_remaining > 0