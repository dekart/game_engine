puts 'Seeding monsters...'

MonsterType.create!(
  :name => "Barbarian",
  :level => 1,
  :health => 100,
  :attack => 1,
  :defence => 1,
  :minimum_damage => 34,
  :maximum_damage => 40,
  :minimum_response => 1,
  :maximum_response => 5,
  :fight_time => 1,
  :maximum_reward_collectors => 1,
  :available_for_friends_invite => false,
  :power_attack_enabled => false,
  :experience => 1,
  :money => 5,
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 1, :apply_on => :victory),
    Payouts::BasicMoney.new(:value => 200, :apply_on => [:victory, :repeat_victory])
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "barbarian.jpg"))
  }]
)

MonsterType.create!(
  :name => "Hydra (multi-player fight)",
  :level => 3,
  :health => 100,
  :attack => 1,
  :defence => 1,
  :minimum_damage => 1,
  :maximum_damage => 5,
  :minimum_response => 1,
  :maximum_response => 5,
  :fight_time => 12,
  :experience => 1,
  :money => 5,
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 1, :apply_on => :victory),
    Payouts::BasicMoney.new(:value => 200, :apply_on => [:victory, :repeat_victory])
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "hydra.jpg"))
  }]
)