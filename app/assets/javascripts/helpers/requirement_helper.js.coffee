window.RequirementHelper =
  requirements: (collection, block)->
    return unless collection?

    content = @.renderTemplate('requirements/list', collection: collection)

    if $.trim(content).length > 0
      @safe block(@safe content)