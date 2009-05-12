def img(name)
  File.open(File.join(RAILS_ROOT, "db", "pictures", "#{name}.jpg"))
end

namespace :app do
  desc "Bootstrap application data"
  task :bootstrap => :environment do
    @missions = {
=begin
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
=end
    }

    @missions.each_pair do |key, value|
      puts "Adding '#{key}'"

      Mission.find_or_create_by_name(key).update_attributes(value)
    end

    @weapons = {
=begin
      "Knife" => {
        :level => 1,
        :description => "",
        :basic_price => 40,
        :effects => Effects::Collection.new(Effects::Attack.new(1)),
        :image => img("weapon 57_al"),
        :placements => "left_hand,right_hand"
      },
=end
    }

    @weapons.each_pair do |key, value|
      puts "Adding '#{key}'"

      Weapon.find_or_create_by_name(key).update_attributes(value)
    end

    @armors = {
=begin
      "Wooden Shield" => {
        :level        => 1,
        :description  => "",
        :basic_price  => 70,
        :effects      => Effects::Collection.new(Effects::Defence.new(1)),
        :placements   => "left_hand,right_hand",
        :image        => img("armor 4")
      },
=end
    }

    @armors.each_pair do |key, value|
      puts "Adding '#{key}'"

      Armor.find_or_create_by_name(key).update_attributes(value)
    end

    @potions = {
=begin
      "Small Potion of Healing" => {
        :level        => 1,
        :description  => "Small potion of magic healing liquor. Heals up to 20 health points.",
        :basic_price  => 50,
        :usable       => true,
        :usage_limit  => 1,
        :effects      => Effects::Collection.new(Effects::RestoreHealth.new(20))
      },
=end
    }

    @potions.each_pair do |key, value|
      puts "Adding '#{key}'"

      Potion.find_or_create_by_name(key).update_attributes(value)
    end
  end
end