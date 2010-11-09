class Character
  module MercenaryRelations
    def random
      first(:offset => rand(size)) if size > 0
    end
  end
end
