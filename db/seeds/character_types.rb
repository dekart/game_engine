puts "Seeding character types..."

CharacterType.create(
  :name         => "Warrior",
  :description  => "High damage and health",
  :attack       => 1,
  :defence      => 1,
  :health       => 100,
  :energy       => 10,
  :stamina      => 10,
  :basic_money  => 10,
  :vip_money    => 0
)

CharacterType.create(
  :name         => "Ranger",
  :description  => "High defence and energy",
  :attack       => 1,
  :defence      => 1,
  :health       => 100,
  :energy       => 10,
  :stamina      => 10,
  :basic_money  => 10,
  :vip_money    => 0
)

CharacterType.create(
  :name         => "Trader",
  :description  => "Any other description you may want",
  :attack       => 1,
  :defence      => 1,
  :health       => 100,
  :energy       => 10,
  :stamina      => 10,
  :basic_money  => 10,
  :vip_money    => 0
)