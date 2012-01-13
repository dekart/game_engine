puts "Seeding items..."

weapons = ItemGroup.create!(:name => "Weapons")

weapons.items.create!(
  :name         => "Knife",
  :level        => 1,
  :basic_price  => 40,
  :effects      => [
    {:type => :attack, :value => 1}
  ],
  :placements   => [:left_hand, :right_hand, :additional],
  :can_be_sold_on_market => true,

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "knife.jpg"))
  }]
)

weapons.items.create!(
  :name         => "Dagger",
  :availability => "gift",
  :level        => 1,
  :basic_price  => 40,
  :effects      => [
    {:type => :attack, :value => 1}
  ],
  :placements   => [:left_hand, :right_hand, :additional],
  :can_be_sold  => false,

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "dagger.jpg"))
  }]
)

armors = ItemGroup.create!(:name => "Armors")

armors.items.create!(
  :name         => "Wooden Shield",
  :level        => 1,
  :basic_price  => 70,
  :effects      => [
    {:type => :defence, :value => 1}
  ],
  :placements   => [:left_hand, :right_hand, :additional],
  
  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "shield.jpg"))
  }]
)

potions = ItemGroup.create!(:name => "Potions")

potions.items.create!(
  :name         => "Potion of Healing",
  :level        => 2,
  :basic_price  => 100,

  :payouts      => Payouts::Collection.new(
    Payouts::HealthPoint.new(:value => 50, :apply_on => :use, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "potion_of_healing.jpg"))
  }]
)

potions.items.create!(
  :name         => "Potion of Upgrade",
  :level        => 2,
  :basic_price  => 50,
  :vip_price    => 5,

  :payouts      => Payouts::Collection.new(
    Payouts::UpgradePoint.new(:value => 5, :apply_on => :use, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "potion_of_upgrade.jpg"))
  }]

)
