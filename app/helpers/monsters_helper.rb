module MonstersHelper
  def monster_health_bar(monster)
    percentage = monster.hp.to_f / monster.health * 100

    percentage_bar(percentage,
      :label => "%s: %d/%d" % [
        MonsterType.human_attribute_name("health"),
        monster.hp,
        monster.health
      ]
    )
  end
end
