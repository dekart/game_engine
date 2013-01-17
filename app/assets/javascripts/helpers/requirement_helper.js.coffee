window.RequirementHelper =
  requirements: (collection, block)->
    return unless collection?

    content = JST['views/requirements/list'](_.extend({collection: collection}))

    if $.trim(content).length > 0
      @safe block(@safe content)