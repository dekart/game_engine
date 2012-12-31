window.RequirementHelper =
  requirements: (collection, block)->
    return unless collection?

    content = JST['views/requirements'](_.extend({collection: collection}, RequirementHelper))

    if $.trim(content).length > 0
      @safe block(@safe content)