window.Item = class extends Spine.Model
  @configure 'Item', 'key', 'group_id', 'name', 'description', 'pictures', 'level', 'purchaseable', 'basic_price', 'vip_price'

  @set: (group, items)->
    @refresh(_.map(items, (i)-> i.group_id = group.id; i ), clear: true)

  requirements: ->
    [
      ['attribute', 'basic_money', @.basic_price, Character.first().basic_money > @.basic_price]
      ['attribute', 'vip_money', @.vip_price, Character.first().vip_money > @.vip_price]
    ]

  group: ->
    ItemGroup.find(@.group_id)

  isEnoughBasicMoney: (amount)->
    return true unless @.basic_price

    amount ?= 1

    Character.first().basic_money >= @.basic_price * amount

  isEnoughVipMoney: (amount)->
    return true unless @.vip_price

    amount ?= 1

    Character.first().vip_money >= @.vip_price * amount

  isEnoughMoney: (amount)->
    @.isEnoughBasicMoney(amount) and @.isEnoughVipMoney(amount)