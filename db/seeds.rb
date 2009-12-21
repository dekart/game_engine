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
  :image        => File.open(Rails.root.join("db", "pictures", "potion_of_healing.jpg")),
  :effects      => Effects::Collection.new(
    Effects::RestoreHealth.new(50)
  )
)

upgrade = potions.items.create!(
  :name         => "Potion of Upgrade",
  :level        => 2,
  :basic_price  => 50,
  :vip_price    => 5,
  :usable       => true,
  :usage_limit  => 1,
  :effects      => Effects::Collection.new(
    Effects::Upgrade.new(5)
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

adventurer.missions.create!(
  :name           => "Pixies",
  :description    => "Pixies are not dangerous for humans, but nevertheless they are quite irritating – stealing minor things, food and sometimes, just for a joke, they would steal babies, which frightens the city inhabitants. Participation in the annual pixie hunt is a good opportunity for newbies.",
  :success_text   => "You have managed to catch a pixie! But there are still plenty of these guys on the roofs.",
  :failure_text   => "Pixie appeared to be more nimble than you thought him to be, it has just slipped from your hands.",
  :complete_text  => "You have caught the last pixie! Even if some of these guys are left in the town, they hide pretty well.",
  :win_amount     => 15,
  :success_chance => 60,
  :repeatable     => true,
  :ep_cost        => 2,
  :experience     => 2,
  :money_min      => 15,
  :money_max      => 25,
  :title          => "Pixie Catcher",
  :payouts        => Payouts::Collection.new(
    Payouts::Item.new(:value => upgrade.id)
  )
)

recruit = MissionGroup.create!(:name => "Recruit", :level => 5)

recruit.missions.create!(
  :name           => "Martial Tulnees",
  :description    => "Tulnees tribe began to suppress the farmers of Gald vale, robbing their livestock and attacking the outward farms. You need to visit nearby villages and find the owners of the surrounding lands.",
  :success_text   => "You visited one of Tulnees settlement and fought the strongest hunter. The tribe will not recover for a long while.",
  :failure_text   => "You came to a settlement and barely escaped from there. The savages appeared to be quite an army.",
  :complete_text  => "You came to the largest tribe settlement. The tribe leader having heard about your deeds, invited you to his hut. In the following conversation you got his promise not to attack the farmers.",
  :win_amount     => 15,
  :success_chance => 70,
  :ep_cost        => 5,
  :experience     => 5,
  :money_min      => 35,
  :money_max      => 60,
  :title          => "Great Hunter"
)

recruit.missions.create!(
  :name           => "Swamp Dragonflies",
  :description    => "Amazing, sometimes frightening and dangerous creatures are constantly breeding in the old gloomy swamp near the Gold river rise. This year a pack of giant dragonflies flew out of it. The insects tend to bite everyone they see, so it is better to kill them.",
  :success_text   => "You have killed a giant dragonfly! The more monsters you destroy, the better for local people it will be.",
  :failure_text   => "A huge dragonfly almost bit off your head! How could you suppose that you are strong enough to deal with the creature?",
  :complete_text  => "You have killed all giant dragonflies! Now everybody can admire the views in safety.",
  :win_amount     => 5,
  :success_chance => 60,
  :ep_cost        => 6,
  :experience     => 8,
  :money_min      => 40,
  :money_max      => 70,
  :title          => "Dragonfly Hunter"
)

recruit.missions.create!(
  :name           => "Wild Centaurs",
  :description    => "Centaurs, half-wild creatures with cannibalistic habits, attack travelers and small villages around Eastern wasteland. Your task is to provide caravans’ passage alone these lands.",
  :success_text   => "You have killed a fierce centaur! It was not a piece of cake, but you have won.",
  :failure_text   => "You came across a centaur which is too strong for you. Now you're better find another opponent.",
  :complete_text  => "You wiped the centaurs off the area! Now caravans may travel safely.",
  :win_amount     => 12,
  :success_chance => 60,
  :ep_cost        => 8,
  :experience     => 12,
  :money_min      => 50,
  :money_max      => 100,
  :title          => "Centaur Killer"
)

recruit.missions.create!(
  :name           => "Goblins’ Caves",
  :description    => "Goblins, settled in Ifen mountains, often steal people and make them work in emerald mines. Regular army sometimes checks several caves, but they cannot embrace all settlements. You need to check the caves where patrols did not get.",
  :success_text   => "You have visited a goblins’ cave and found several men there. You managed to free them.",
  :failure_text   => "The very moment you have entered a settlement, someone attempted to kill you. They were stronger and you had to retreat.",
  :complete_text  => "You have checked through all the settlements marked on the map. Well done!",
  :win_amount     => 15,
  :success_chance => 70,
  :ep_cost        => 4,
  :experience     => 4,
  :money_min      => 25,
  :money_max      => 45,
  :title          => "Goblin Suppressor"
)

recruit.missions.create!(
  :name           => "Baron Vagra’s Ring",
  :description    => "Baron Vagra, being young and flippant, played away his family ring to centurion. Now baron is old and to legally form his will and leave heritage to his son, he needs to stamp the document with the family insignia. Find the ring and give it back to baron.",
  :success_text   => "You got on the trail of an old soldier in a village, but unfortunately the man you are seeking had moved long ago. You’ve got to continue your search.",
  :failure_text   => "Someone told you about a man looking like the one you lok for. But you’ve met him and he is not the one you need.",
  :complete_text  => "You asked about an old soldier and people showed you a road to a farm where an old man lived. You met a lame old man there. At first he didn’t understand your question, but then he remembered the ring, brought it out and gave it to you, asking only to tell some words to baron. But when you delivered the ring to baron, you didn’t dare to tell him these words. ",
  :win_amount     => 12,
  :success_chance => 75,
  :ep_cost        => 4,
  :experience     => 3,
  :money_min      => 20,
  :money_max      => 65,
  :title          => "Baron Assistant"
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