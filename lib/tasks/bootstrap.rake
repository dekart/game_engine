def img(name)
  File.open(File.join(RAILS_ROOT, "db", "pictures", "#{name}.jpg"))
end

namespace :app do
  desc "Bootstrap application data"
  task :bootstrap => :environment do
    @missions = {
      "Deratization" => {
        :level          => 1,
        :description    => "The rats are breeding by amazing quantities in capital underground conduits. The biggest and impudent ones have already begun visiting houses, stealing food and even bit several citizens. Local authorities announced  a  reward for every destroyed rat’s nest.",
        :success_text   => "You caught a giant rat! But something is still gritting in the conduits.",
        :failure_text   => "You searched through a lot of conduits, but all the rats you have met are not worthy. Probably, you should seek more thoroughly.",
        :complete_text  => "You caught a giant rat! The remaining minor rodents are not dangerous for the citizens.",
        :win_amount     => 20,
        :title          => "Rat Trapper",
        :success_chance => 80,
        :ep_cost        => 1,
        :experience     => 1,
        :money_min      => 8,
        :money_max      => 15
      },
      "Pixies" => {
        :level          => 1,
        :description    => "Pixies are not dangerous for humans, but nevertheless they are quite irritating – stealing minor things, food and sometimes, just for a joke, they would steal babies, which frightens the city inhabitants. Participation in the annual pixie hunt is a good opportunity for newbies.",
        :success_text   => "You have managed to catch a pixie! But there are still plenty of these guys on the roofs.",
        :failure_text   => "Pixie appeared to be more nimble than you thought him to be, it has just slipped from your hands",
        :complete_text  => "You have caught the last pixie! Even if some of these guys are left in the town, they hide pretty well.",
        :win_amount     => 15,
        :title          => "Pixie Catcher",
        :success_chance => 60,
        :ep_cost        => 2,
        :experience     => 2,
        :money_min      => 15,
        :money_max      => 25
      },
      "Lurchers" => {
        :level          => 1,
        :description    => "A band of skillful lurchers appeared in the town and now the property of its citizens is at risk. Help the guards to catch and punish the criminals.",
        :success_text   => "You have caught a lurcher! But the guards still report on the complaints from the citizens.",
        :failure_text   => "The lurcher you have just caught managed to escape. Next time you must pay more attention",
        :complete_text  => "You have managed to arrest the lurchers’ boss! Now the theft quantity will surely decrease.",
        :win_amount     => 10,
        :title          => "Policeman",
        :success_chance => 60,
        :ep_cost        => 2,
        :experience     => 3,
        :money_min      => 15,
        :money_max      => 35
      },
      "Debtor" => {
        :level          => 1,
        :description    => "Metropolitan merchant asked you to help him find one of his partners, owing him a considerable amount of money. This bacchanal is well-known in many local pubs, so it will take a while to find him.",
        :success_text   => "The person that you look for was seen recently in a tavern. You’ve got to continue your search.",
        :failure_text   => "You’ve been pointed on to a guy, but he appeared to be an  average drinker.",
        :complete_text  => "Finally, You’ve found the debtor in a tavern. The guy doesn’t seem to have any money, but there are some mortgages belonging to the merchant. You’ve got to give them back to the owner.",
        :win_amount     => 10,
        :title          => "Debt Recoverer",
        :success_chance => 70,
        :ep_cost        => 4,
        :experience     => 3,
        :money_min      => 20,
        :money_max      => 55
      },
      "Martial Tulnees" => {
        :level          => 3,
        :description    => "Tulnees tribe began to suppress the farmers of Gald vale, robbing their livestock and attacking the outward farms. You need to visit nearby villages and find the owners of the surrounding lands.",
        :success_text   => "You visited one of Tulnees settlement and fought the strongest hunter. The tribe will not recover for a long while.",
        :failure_text   => "You came to a settlement and barely escaped from there. The savages appeared to be quite an army.",
        :complete_text  => "You came to the largest tribe settlement. The tribe leader having heard about your deeds, invited you to his hut. In the following conversation you got his promise not to attack the farmers. The tribe leader gave you some ring as the sign of his friendship.",
        :win_amount     => 15,
        :title          => "Great Hunter",
        :success_chance => 70,
        :ep_cost        => 5,
        :experience     => 5,
        :money_min      => 35,
        :money_max      => 60
      },
      "Baron Vagra’s Ring" => {
        :level          => 3,
        :description    => "Baron Vagra, being young and flippant, played away his family ring to centurion. Now baron is old and to legally form his will and leave heritage to his son, he needs to stamp the document with the family insignia. Find the ring and give it back to baron.",
        :success_text   => "You got on the trail of an old soldier in a village, but unfortunately the man you are seeking had moved long ago. You’ve got to continue your search.",
        :failure_text   => "Someone told you about a man looking like the one you lok for. But you’ve met him and he is not the one you need.",
        :complete_text  => "You asked about an old soldier and people showed you a road to a farm where an old man lived. You met a lame old man there. At first he didn’t understand your question, but then he remembered the ring, brought it out and gave it to you, asking only to tell some words to baron. But when you delivered the ring to baron, you didn’t dare to tell him these words.",
        :win_amount     => 12,
        :title          => "Baron Assistant",
        :success_chance => 75,
        :ep_cost        => 4,
        :experience     => 3,
        :money_min      => 20,
        :money_max      => 65
      },
      "Orcs in Iza" => {
        :level          => 3,
        :description    => "Minor orc bands living in the mountains are stealing the livestock from the pastries. Regular army is useless – orcs hide from them in the rocks. You should punish these rascals and bring peace to the farmers.",
        :success_text   => "You defeated a minor orc group! The evidently didn’t expect to meet such a strong enemy.",
        :failure_text   => "You met a way too large group of orcs. You had to retreat.",
        :complete_text  => "You eliminated the last orcs in the region. Farmers organized a small feast in your name with singing and dancing.",
        :win_amount     => 15,
        :title          => "Terror of Orcs",
        :success_chance => 70,
        :ep_cost        => 6,
        :experience     => 8,
        :money_min      => 30,
        :money_max      => 60
      },
      "Goblins’ Caves" => {
        :level          => 3,
        :description    => "Goblins, settled in Ifen mountains, often steal people and make them work in emerald mines. Regular army sometimes checks several caves, but they cannot embrace all settlements. You need to check the caves where patrols did not get.",
        :success_text   => "You have visited a goblins’ cave and found several men there. You managed to free them.",
        :failure_text   => "The very moment you have entered a settlement, someone attempted to kill you. They were stronger and you had to retreat.",
        :complete_text  => "You have checked through all the settlements marked on the map. Well done!",
        :win_amount     => 15,
        :title          => "Goblin Suppressor",
        :success_chance => 70,
        :ep_cost        => 4,
        :experience     => 4,
        :money_min      => 25,
        :money_max      => 45
      },
      "Wild Centaurs" => {
        :level          => 5,
        :description    => "Centaurs, half-wild creatures with cannibalistic habits, attack travelers and small villages around Eastern wasteland. Your task is to provide caravans’ passage alone these lands.",
        :success_text   => "You have killed a fierce centaur! It was not a piece of cake, but you have won.",
        :failure_text   => "You came across a centaur which is too strong for you. Now you're better find another opponent.",
        :complete_text  => "You wiped the centaurs off the area! Now caravans may travel safely.",
        :win_amount     => 12,
        :title          => "Centaur Killer",
        :success_chance => 60,
        :ep_cost        => 8,
        :experience     => 12,
        :money_min      => 50,
        :money_max      => 100
      },
      "Swamp Dragonflies" => {
        :level          => 5,
        :description    => "Amazing, sometimes frightening and dangerous creatures are constantly breeding in the old gloomy swamp near the Gold river rise. This year a pack of giant dragonflies flew out of it. The insects tend to bite everyone they see, so it is better to kill them.",
        :success_text   => "You have killed a giant dragonfly! The more monsters you destroy, the better for local people it will be.",
        :failure_text   => "A huge dragonfly almost bit off your head! How could you suppose that you are strong enough to deal with the creature?",
        :complete_text  => "You have killed all giant dragonflies! Now everybody can admire the views in safety.",
        :win_amount     => 5,
        :title          => "Dragonfly Hunter",
        :success_chance => 60,
        :ep_cost        => 6,
        :experience     => 8,
        :money_min      => 40,
        :money_max      => 70
      }
    }

    @missions.each_pair do |key, value|
      puts "Adding '#{key}'"

      Mission.find_or_create_by_name(key).update_attributes(value)
    end

    @weapons = {
      "Knife" => {
        :level => 1,
        :description => "",
        :basic_price => 40,
        :effects => Effects::Collection.new(Effects::Attack.new(1)),
        :image => img("weapon 57_al"),
        :placements => "left_hand,right_hand"
      },
      "Soldier Sword" => {
        :level => 1,
        :description => "",
        :basic_price => 180,
        :effects => Effects::Collection.new(Effects::Attack.new(4), Effects::Defence.new(1)),
        :image => img("weapon 100_n"),
        :placements => "left_hand,right_hand"
      },
      "Trapper Bow" => {
        :level => 1,
        :description => "",
        :basic_price => 100,
        :effects => Effects::Collection.new(Effects::Attack.new(3)),
        :image => img("weapon 20_n"),
        :placements => "left_hand,right_hand"
      },
      "Lumberjack Axe" => {
        :level => 1,
        :description => "",
        :basic_price => 70,
        :effects => Effects::Collection.new(Effects::Attack.new(2)),
        :image => img("weapon 25_n"),
        :placements => "left_hand,right_hand"
      },
      "Battle Staff" => {
        :level => 3,
        :description => "",
        :basic_price => 160,
        :effects => Effects::Collection.new(Effects::Attack.new(4)),
        :image => img("weapon 27_n"),
        :placements => "left_hand,right_hand"
      },
      "Iron Dagger" => {
        :level => 3,
        :description => "",
        :basic_price => 170,
        :effects => Effects::Collection.new(Effects::Attack.new(3), Effects::Defence.new(1)),
        :image => img("weapon 108_1_n"),
        :placements => "left_hand,right_hand"
      },
      "Halfling Bow" => {
        :level => 3,
        :description => "",
        :basic_price => 200,
        :effects => Effects::Collection.new(Effects::Attack.new(5)),
        :image => img("weapon 176_2"),
        :placements => "left_hand,right_hand"
      },
      "Orc Hammer" => {
        :level => 5,
        :description => "",
        :basic_price => 220,
        :effects => Effects::Collection.new(Effects::Attack.new(6), Effects::Defence.new(2)),
        :image => img("weapon 84_n"),
        :placements => "left_hand,right_hand"
      },
      "Black Steel Dagger" => {
        :level => 5,
        :description => "",
        :basic_price => 700,
        :effects => Effects::Collection.new(Effects::Attack.new(7), Effects::Defence.new(3)),
        :image => img("weapon 55_m"),
        :placements => "left_hand,right_hand"
      },
      "Guardian Sword" => {
        :level => 5,
        :description => "",
        :basic_price => 1200,
        :effects => Effects::Collection.new(Effects::Attack.new(9), Effects::Defence.new(3)),
        :image => img("weapon 17_m"),
        :placements => "left_hand,right_hand"
      },
      "Cloud Poleaxe" => {
        :level => 5,
        :description => "",
        :basic_price => 1000,
        :vip_price => 5,
        :effects => Effects::Collection.new(Effects::Attack.new(13), Effects::Defence.new(5)),
        :image => img("weapon 38_l"),
        :placements => "left_hand,right_hand"
      },
      "Spear" => {
        :level => 8,
        :description => "",
        :basic_price => 1800,
        :effects => Effects::Collection.new(Effects::Attack.new(12), Effects::Defence.new(4)),
        :image => img("weapon 62"),
        :placements => "left_hand,right_hand"
      },
      "Goblin Broadsword" => {
        :level => 8,
        :description => "",
        :basic_price => 2200,
        :effects => Effects::Collection.new(Effects::Attack.new(14), Effects::Defence.new(4)),
        :image => img("weapon 29_n"),
        :placements => "left_hand,right_hand"
      },
      "Thick Dagger" => {
        :level => 8,
        :description => "",
        :basic_price => 1800,
        :effects => Effects::Collection.new(Effects::Attack.new(10), Effects::Defence.new(4)),
        :image => img("weapon 3_l"),
        :placements => "left_hand,right_hand"
      },
      "Centaur Bow" => {
        :level => 8,
        :description => "",
        :basic_price => 2000,
        :effects => Effects::Collection.new(Effects::Attack.new(12), Effects::Defence.new(5)),
        :image => img("weapon 176_3"),
        :placements => "left_hand,right_hand"
      },
      "Barbarian Hammer" => {
        :level => 8,
        :description => "",
        :basic_price => 2000,
        :vip_price => 10,
        :effects => Effects::Collection.new(Effects::Attack.new(18), Effects::Defence.new(6)),
        :image => img("weapon 26_l"),
        :placements => "left_hand,right_hand"
      },
      "Mangena Root Staff" => {
        :level => 10,
        :description => "",
        :basic_price => 3500,
        :effects => Effects::Collection.new(Effects::Attack.new(16), Effects::Defence.new(6)),
        :image => img("weapon 42_1_n"),
        :placements => "left_hand,right_hand"
      },
      "Black Steel Sword" => {
        :level => 10,
        :description => "",
        :basic_price => 4000,
        :effects => Effects::Collection.new(Effects::Attack.new(18), Effects::Defence.new(5)),
        :image => img("weapon 113_n"),
        :placements => "left_hand,right_hand"
      },
      "Leaf Dagger" => {
        :level => 10,
        :description => "",
        :basic_price => 2800,
        :effects => Effects::Collection.new(Effects::Attack.new(14), Effects::Defence.new(4)),
        :image => img("weapon 176_1"),
        :placements => "left_hand,right_hand"
      },
      "Night Warrior Dagger" => {
        :level => 15,
        :description => "",
        :basic_price => 4500,
        :effects => Effects::Collection.new(Effects::Attack.new(20), Effects::Defence.new(6)),
        :image => img("weapon 92_n"),
        :placements => "left_hand,right_hand"
      },
      "Fine Steel Sword" => {
        :level => 15,
        :description => "",
        :basic_price => 5200,
        :effects => Effects::Collection.new(Effects::Attack.new(23), Effects::Defence.new(7)),
        :image => img("weapon 110_n"),
        :placements => "left_hand,right_hand"
      },
      "Long Spear" => {
        :level => 15,
        :description => "",
        :basic_price => 6000,
        :effects => Effects::Collection.new(Effects::Attack.new(20), Effects::Defence.new(9)),
        :image => img("weapon 176_4"),
        :placements => "left_hand,right_hand"
      },
      "Dwarf Flail" => {
        :level => 15,
        :description => "",
        :basic_price => 6200,
        :vip_price => 5,
        :effects => Effects::Collection.new(Effects::Attack.new(30), Effects::Defence.new(10)),
        :image => img("weapon 81_nn"),
        :placements => "left_hand,right_hand"
      },
      "Pirate Broadsword" => {
        :level => 20,
        :description => "",
        :basic_price => 8000,
        :effects => Effects::Collection.new(Effects::Attack.new(28), Effects::Defence.new(10)),
        :image => img("weapon 9"),
        :placements => "left_hand,right_hand"
      },
      "Griffon Beak Dagger" => {
        :level => 20,
        :description => "",
        :basic_price => 9000,
        :effects => Effects::Collection.new(Effects::Attack.new(28), Effects::Defence.new(12)),
        :image => img("weapon 139_n"),
        :placements => "left_hand,right_hand"
      },
      "Steel Club" => {
        :level => 20,
        :description => "",
        :basic_price => 9200,
        :effects => Effects::Collection.new(Effects::Attack.new(31), Effects::Defence.new(9)),
        :image => img("weapon 111_s"),
        :placements => "left_hand,right_hand"
      },
      "Mercenary Halberd" => {
        :level => 20,
        :description => "",
        :basic_price => 9800,
        :effects => Effects::Collection.new(Effects::Attack.new(30), Effects::Defence.new(13)),
        :image => img("weapon 120_n"),
        :placements => "left_hand,right_hand"
      },
      "Werewolf Axe" => {
        :level => 20,
        :description => "",
        :basic_price => 9500,
        :vip_price => 10,
        :effects => Effects::Collection.new(Effects::Attack.new(36), Effects::Defence.new(14)),
        :image => img("weapon 79_m"),
        :placements => "left_hand,right_hand"
      },
    }

    @weapons.each_pair do |key, value|
      puts "Adding '#{key}'"

      Weapon.find_or_create_by_name(key).update_attributes(value)
    end

    @armors = {
      "Wooden Shield" => {
        :level        => 1,
        :description  => "",
        :basic_price  => 70,
        :effects      => Effects::Collection.new(Effects::Defence.new(1)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 4")
      },
      "Steel Helmet" => {
        :level        => 1,
        :description  => "",
        :basic_price  => 90,
        :effects      => Effects::Collection.new(Effects::Defence.new(2)),
        :placements   => "head",
        :image        => img("armor 6_i")
      },
      "Spearman Cap" => {
        :level        => 5,
        :description  => "",
        :basic_price  => 500,
        :effects      => Effects::Collection.new(Effects::Defence.new(5)),
        :placements   => "head",
        :image        => img("armor28")
      },
      "Goblin Shield" => {
        :level        => 5,
        :description  => "",
        :basic_price  => 500,
        :effects      => Effects::Collection.new(Effects::Defence.new(5)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 35")
      },
      "Soldier Shield" => {
        :level        => 10,
        :description  => "",
        :basic_price  => 800,
        :effects      => Effects::Collection.new(Effects::Defence.new(6)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 23")
      },
      "Large Soldier Shield" => {
        :level        => 10,
        :description  => "",
        :basic_price  => 1200,
        :effects      => Effects::Collection.new(Effects::Defence.new(8)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 29_1")
      },
      "Ogre Skin Helmet" => {
        :level        => 10,
        :description  => "",
        :basic_price  => 1000,
        :effects      => Effects::Collection.new(Effects::Defence.new(7)),
        :placements   => "head",
        :image        => img("armor 8_al")
      },
      "Knight Armor" => {
        :level        => 10,
        :description  => "",
        :basic_price  => 3500,
        :vip_price    => 10,
        :effects      => Effects::Collection.new(Effects::Defence.new(25)),
        :placements   => "body",
        :image        => img("armor3")
      },
      "Steel Shield" => {
        :level        => 15,
        :description  => "",
        :basic_price  => 2000,
        :effects      => Effects::Collection.new(Effects::Defence.new(10)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 32")
      },
      "Centaur Stone Shield" => {
        :level        => 15,
        :description  => "",
        :basic_price  => 3000,
        :effects      => Effects::Collection.new(Effects::Defence.new(12)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 33")
      },
      "Barbarian Helmet" => {
        :level        => 15,
        :description  => "",
        :basic_price  => 6000,
        :effects      => Effects::Collection.new(Effects::Defence.new(15)),
        :placements   => "head",
        :image        => img("armor 38")
      },
      "Legionary Shield" => {
        :level        => 15,
        :description  => "",
        :basic_price  => 3500,
        :vip_price    => 5,
        :effects      => Effects::Collection.new(Effects::Defence.new(15)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 25")
      },
      "Marble Shield" => {
        :level        => 20,
        :description  => "",
        :basic_price  => 4500,
        :effects      => Effects::Collection.new(Effects::Defence.new(18)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 29_2")
      },
      "Rough Silver Shield" => {
        :level        => 20,
        :description  => "",
        :basic_price  => 8000,
        :effects      => Effects::Collection.new(Effects::Defence.new(24)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 39")
      },
      "Griffon Claw Shield" => {
        :level        => 20,
        :description  => "",
        :basic_price  => 8000,
        :vip_price    => 10,
        :effects      => Effects::Collection.new(Effects::Defence.new(30)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 40")
      },
      "Roderick's Family Shield" => {
        :level        => 25,
        :description  => "",
        :basic_price  => 15000,
        :effects      => Effects::Collection.new(Effects::Defence.new(30)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 41")
      },
      "Captain Helmet" => {
        :level        => 25,
        :description  => "",
        :basic_price  => 12000,
        :effects      => Effects::Collection.new(Effects::Defence.new(20)),
        :placements   => "head",
        :image        => img("armor 19_n1")
      },
      "Cavalry Helmet" => {
        :level        => 25,
        :description  => "",
        :basic_price  => 18000,
        :effects      => Effects::Collection.new(Effects::Defence.new(25)),
        :placements   => "head",
        :image        => img("armor 7_a")
      },
      "Assassin Helmet" => {
        :level        => 25,
        :description  => "",
        :basic_price  => 15000,
        :vip_price    => 20,
        :effects      => Effects::Collection.new(Effects::Defence.new(30)),
        :placements   => "head",
        :image        => img("armor 34")
      },
      "Wolverine Shield" => {
        :level        => 30,
        :description  => "",
        :basic_price  => 22000,
        :effects      => Effects::Collection.new(Effects::Defence.new(36)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 31")
      },
      "Knight Shield" => {
        :level        => 30,
        :description  => "",
        :basic_price  => 27000,
        :effects      => Effects::Collection.new(Effects::Defence.new(40)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 5")
      },
      "Bodyguard Helmet" => {
        :level        => 30,
        :description  => "",
        :basic_price  => 20000,
        :effects      => Effects::Collection.new(Effects::Defence.new(30)),
        :placements   => "head",
        :image        => img("armor 16")
      },
      "General Helmet" => {
        :level        => 30,
        :description  => "",
        :basic_price  => 23000,
        :vip_price    => 10,
        :effects      => Effects::Collection.new(Effects::Defence.new(38)),
        :placements   => "head",
        :image        => img("armor 12")
      }
    }

    @armors.each_pair do |key, value|
      puts "Adding '#{key}'"

      Armor.find_or_create_by_name(key).update_attributes(value)
    end

    @potions = {
      "Small Potion of Healing" => {
        :level        => 1,
        :description  => "Small potion of magic healing liquor. Heals up to 20 health points.",
        :basic_price  => 50,
        :usable       => true,
        :usage_limit  => 1,
        :effects      => Effects::Collection.new(Effects::RestoreHealth.new(20))
      },
      "Small Potion of Refresh" => {
        :level        => 1,
        :description  => "Small potion of refreshing liquor. Heals up to 5 energy points.",
        :basic_price  => 10,
        :vip_price    => 1,
        :usable       => true,
        :usage_limit  => 1,
        :effects      => Effects::Collection.new(Effects::RestoreEnergy.new(5))
      }
    }

    @potions.each_pair do |key, value|
      puts "Adding '#{key}'"

      Potion.find_or_create_by_name(key).update_attributes(value)
    end
  end
end