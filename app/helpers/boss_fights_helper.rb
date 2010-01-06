module BossFightsHelper
  def boss_fight_health_bar(fight)
    percentage = fight.health.to_f / fight.boss.health * 100

    percentage_bar(percentage, "%d/%d" % [fight.health, fight.boss.health])
  end
end
