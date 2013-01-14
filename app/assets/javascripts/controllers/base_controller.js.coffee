window.BaseController = class extends Spine.Controller
  prepareHelpers: ()->
    @helpers = _.extend({}, FacebookHelper, RewardHelper, MonstersHelper, DesignHelper)

  renderTemplate: (path, attributes)->
    @.prepareHelpers() unless @helpers?

    JST["views/#{ path }"]( _.extend({}, attributes, @helpers) )