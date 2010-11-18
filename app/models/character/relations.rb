class Character
  module Relations
    def effective_size
      maximum_size? ? Setting.i(:relation_max_alliance_size) : size + 1
    end

    def maximum_size?
      size + 1 >= Setting.i(:relation_max_alliance_size)
    end
  end
end
