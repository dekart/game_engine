window.Item = class extends Spine.Model
  @configure 'Item', 'key', 'group_id', 'name', 'description', 'pictures', 'level', 'purchaseable', 'basic_price', 'vip_price'

  @set: (group, items)->
    @refresh(_.map(items, (i)-> i.group_id = group.id; i ), clear: true)

  requirements: ->
    [
      ['attribute', 'basic_money', @.basic_price, Character.first().basic_money > @.basic_price]
      ['attribute', 'vip_money', @.vip_price, Character.first().vip_money > @.vip_price]
    ]