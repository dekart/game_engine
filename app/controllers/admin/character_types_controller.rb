class Admin::CharacterTypesController < Admin::BaseController
  def index
    @character_types = GameData::CharacterType.collection.values
  end
end
