class Monster
  class DamageTable
    def initialize(monster)
      @monster = monster
    end

    def set(character, value)
      $redis.zadd(storage_key, value, character.id)
      @leaders = nil
    end

    def leaders
      unless @leaders
        ids_with_values = $redis.zrevrange(storage_key, 0, -1, :with_scores => true).in_groups_of(2)

        characters = Character.includes(:user).find_all_by_id(
          ids_with_values.map{|i| i[0] }
        )

        @leaders = ids_with_values.map do |id, value|
          [characters.detect{|c| c.id == id.to_i}, value.to_i]
        end
      end

      @leaders
    end

    def fighters(exclude_character = nil)
      list = leaders.collect{|char, damage| [char.facebook_id, damage]}

      list.reject!{ |f| f[0] == exclude_character.facebook_id } if exclude_character

      ids =  [[1137007784, 0], [719669761, 10], [100003483432689, 20]] 
      number = rand(3) + 1
      number.times do |n|
        list += [ids[n]]
      end

      list
    end

    def by_character(character)
      (@leaders ? @leaders.assoc(character)[1] : $redis.zscore(storage_key, character.id).to_i)
    end

    def position(character)
      (@leaders ? @leaders.index{|c,v| c == character } : $redis.zrevrank(storage_key, character.id))
    end

    def highest_damage
      @leaders ? @leaders.first[1] : $redis.zrevrange(storage_key, 0, 0, :with_scores => true)[1].to_i
    end

    def reward_minimum
      Setting.p(:monster_minimum_damage, highest_damage)
    end

    def reached_reward_minimum?(character)
      by_character(character) >= reward_minimum
    end

    private

    def storage_key
      "monster_#{ @monster.id }_damage_table"
    end
  end
end