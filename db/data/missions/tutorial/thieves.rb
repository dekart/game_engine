
GameData::Mission.define :thieves do |m|

  m.group = :tutorial

  m.tags = [:repeatable]

  m.reward_on :mission_complete do |r|
    r.give_upgrade_points 1
  end

  m.level do |l|
    l.steps = 4

    l.requires do |r|

      r.ep = 2

    end

    l.reward_on :success do |r|

      r.take_energy 2
      r.give_experience 4
      r.give_basic_money 15..20

    end

    l.reward_on :repeat_success do |r|

      r.take_energy 2
      r.give_experience 4
      r.give_basic_money 15..20

    end

    l.reward_on :failure do |r|

      r.take_energy 2

    end

    l.reward_on :repeat_failure do |r|

      r.take_energy 2

    end

    l.reward_on :level_complete do |r|
      r.give_vip_money 1
    end

  end

  m.level do |l|
    l.steps = 2

    l.requires do |r|
      #r.attack = 2

      r.ep = 1

    end

    l.reward_on :success do |r|

      r.take_energy 1
      r.give_experience 1
      r.give_basic_money 1..2

    end

    l.reward_on :repeat_success do |r|

      r.take_energy 1
      r.give_experience 1
      r.give_basic_money 1..2

    end

    l.reward_on :failure do |r|

      r.take_energy 1

    end

    l.reward_on :repeat_failure do |r|

      r.take_energy 1

    end

  end

end
