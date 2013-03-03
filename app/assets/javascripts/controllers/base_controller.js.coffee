window.BaseController = class extends Spine.Controller
  helpers: (other_helpers...)->
    @helper_cache ?= _.extend({}, FacebookHelper, RewardHelper, RequirementHelper, DesignHelper, other_helpers...)

  renderTemplate: (path, attributes...)->
    JST["views/#{ path }"]( _.extend({}, @.helpers(), attributes...) )

  renderPreloader: ->
    @html(
      I18n.t('common.loading')
    )
