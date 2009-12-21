facebook_config = YAML.load_file(Rails.root.join("config", "facebooker.yml"))[Rails.env]

Configuration.create! if Configuration.count == 0

weapons = ItemGroup.create!(:name => "Weapons")

knife = weapons.items.create!(
  :name         => "Knife",
  :level        => 1,
  :basic_price  => 40,
  :attack       => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "knife.jpg"))
)

armors = ItemGroup.create!(:name => "Armors")

shield = armors.items.create!(
  :name         => "Wooden Shield",
  :level        => 1,
  :basic_price  => 70,
  :defence      => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "shield.jpg"))
)

potions = ItemGroup.create!(:name => "Potions")

healing = potions.items.create!(
  :name         => "Potion of Healing",
  :level        => 2,
  :basic_price  => 100,
  :usable       => true,
  :usage_limit  => 1,
  :effects      => Effects::Collection.new(
    Effects::RestoreHealth.new(50)
  )
)

tutorial = MissionGroup.create!(:name => "Tutorial", :level => 1)

tutorial.missions.create!(
  :name           => "Thieves",
  :description    => "Thieves steal money from people. Arrest them.",
  :success_text   => "You arrested a thief!",
  :failure_text   => "You failed to arrest a thief!",
  :complete_text  => "You arrested all thieves!",
  :win_amount     => 3,
  :success_chance => 100,
  :ep_cost        => 2,
  :experience     => 3,
  :money_min      => 15,
  :money_max      => 20,
  :title          => "Police Helper",
  :payouts        => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 5)
  )
)

adventurer = MissionGroup.create!(:name => "Adventurer", :level => 2)

adventurer.missions.create!(
  :name           => "Deratization",
  :description    => "The rats are breeding by amazing quantities in capital underground conduits. The biggest and impudent ones have already begun visiting houses, stealing food and even bit several citizens. Local authorities announced  a  reward for every destroyed rat’s nest.",
  :success_text   => "You caught a giant rat! But something is still gritting in the conduits.",
  :failure_text   => "You searched through a lot of conduits, but all the rats you have met are not worthy. Probably, you should seek more thoroughly.",
  :complete_text  => "You caught a giant rat! The remaining minor rodents are not dangerous for the citizens.",
  :win_amount     => 20,
  :success_chance => 100,
  :repeatable     => true,
  :ep_cost        => 1,
  :experience     => 2,
  :money_min      => 8,
  :money_max      => 15,
  :title          => "Rat Trapper",
  :requirements   => Requirements::Collection.new(
    Requirements::Item.new(:value => knife.id)
  ),
  :payouts        => Payouts::Collection.new(
    Payouts::Item.new(:value => healing.id)
  )
)

adventurer.missions.create!(
  :name           => "Debtor",
  :description    => "Metropolitan merchant asked you to help him find one of his partners, owing him a considerable amount of money. This bacchanal is well-known in many local pubs, so it will take a while to find him.",
  :success_text   => "The person that you look for was seen recently in a tavern. You’ve got to continue your search.",
  :failure_text   => "You’ve been pointed on to a guy, but he appeared to be an  average drinker.",
  :complete_text  => "Finally, You’ve found the debtor in a tavern. The guy doesn’t seem to have any money, but there are some mortgages belonging to the merchant. You’ve got to give them back to the owner.",
  :win_amount     => 10,
  :success_chance => 70,
  :ep_cost        => 4,
  :experience     => 3,
  :money_min      => 20,
  :money_max      => 55,
  :title          => "Debt Recoverer"
)

adventurer.missions.create!(
  :name           => "Orcs in Iza",
  :description    => "Minor orc bands living in the mountains are stealing the livestock from the pastries. Regular army is useless – orcs hide from them in the rocks. You should punish these rascals and bring peace to the farmers.",
  :success_text   => "You defeated a minor orc group! The evidently didn’t expect to meet such a strong enemy.",
  :failure_text   => "You met a way too large group of orcs. You had to retreat.",
  :complete_text  => "You eliminated the last orcs in the region. Farmers organized a small feast in your name with singing and dancing.",
  :win_amount     => 15,
  :success_chance => 70,
  :ep_cost        => 6,
  :experience     => 8,
  :money_min      => 30,
  :money_max      => 60,
  :title          => "Terror of Orcs"
)

adventurer.missions.create!(
  :name           => "Lurchers",
  :description    => "A band of skillful lurchers appeared in the town and now the property of its citizens is at risk. Help the guards to catch and punish the criminals.",
  :success_text   => "You have caught a lurcher! But the guards still report on the complaints from the citizens.",
  :failure_text   => "The lurcher you have just caught managed to escape. Next time you must pay more attention.",
  :complete_text  => "You have managed to arrest the lurchers’ boss! Now the theft quantity will surely decrease.",
  :win_amount     => 10,
  :success_chance => 60,
  :repeatable     => true,
  :ep_cost        => 2,
  :experience     => 3,
  :money_min      => 15,
  :money_max      => 35,
  :title          => "Policeman"
)

mill = PropertyType.create!(
  :name         => "Windmill",
  :level        => 1,
  :basic_price  => 3000,
  :income       => 5,
  :inflation    => 200,
  :image        => File.open(Rails.root.join("db", "pictures", "mill.jpg"))
)

Tip.create!(
  :text => "Put your money to the <a href=\"/#{facebook_config["canvas_page_name"]}/bank_operations/new\">Treasure</a> and no one will be able to grab it in the fight"
)

Tip.create!(
  :text => "Properties give you hourly income. Purchase <a href=\"/#{facebook_config["canvas_page_name"]}/properties/new\">more properties</a> to get more money in the future."
)