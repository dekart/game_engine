window.BaseController = class extends Spine.Controller
  prepareHelpers: (other_helpers...)->
    @helpers = _.extend({}, FacebookHelper, RewardHelper, RequirementHelper, DesignHelper, other_helpers...)

  renderTemplate: (path, attributes)->
    @.prepareHelpers() unless @helpers?

    JST["views/#{ path }"]( _.extend({}, attributes, @helpers) )

  renderPreloader: ->
    @html(
      I18n.t('common.loading')
    )
