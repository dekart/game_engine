window.RewardHelper =
  rewards: (collection, block)->
    return unless collection?

    content = JST['views/rewards'](_.extend({reward: collection, mode: 'rewards'}, RewardHelper))

    if $.trim(content).length > 0
      @safe block(@safe content)

  spendings: (collection, block)->
    return unless collection?

    content = JST['views/rewards'](_.extend({reward: collection, mode: 'spendings'}, RewardHelper))

    if $.trim(content).length > 0
      @safe block(@safe content)
