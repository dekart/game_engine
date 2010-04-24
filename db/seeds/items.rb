puts "Seeding items..."

weapons = ItemGroup.create!(:name => "Weapons")

weapons.items.create!(
  :name         => "Knife",
  :level        => 1,
  :basic_price  => 40,
  :attack       => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "knife.jpg"))
)

weapons.items.create!(
  :name         => "Dagger",
  :availability => "gift",
  :level        => 1,
  :basic_price  => 40,
  :attack       => 1,
  :can_be_sold  => false,
  :image        => File.open(Rails.root.join("db", "pictures", "dagger.jpg"))
)

armors = ItemGroup.create!(:name => "Armors")

armors.items.create!(
  :name         => "Wooden Shield",
  :level        => 1,
  :basic_price  => 70,
  :defence      => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "shield.jpg"))
)

potions = ItemGroup.create!(:name => "Potions")

potions.items.create!(
  :name         => "Potion of Healing",
  :level        => 2,
  :basic_price  => 100,
  :usable       => true,
  :usage_limit  => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "potion_of_healing.jpg")),
  :effects      => Effects::Collection.new(
    Effects::RestoreHealth.new(50)
  )
)

potions.items.create!(
  :name         => "Potion of Upgrade",
  :level        => 2,
  :basic_price  => 50,
  :vip_price    => 5,
  :usable       => true,
  :usage_limit  => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "potion_of_upgrade.jpg")),
  :effects      => Effects::Collection.new(
    Effects::Upgrade.new(5)
  )
)
