def img(name)
  File.open(File.join(RAILS_ROOT, "db", "pictures", "samples", "#{name}.jpg"))
end

namespace :app do
  namespace :bootstrap do
    desc "Bootstrap sample application data"
    task :samples => :environment do
      Rake::Task["app:bootstrap:samples:item_groups"].execute(nil)
      Rake::Task["app:bootstrap:samples:weapons"].execute(nil)
      Rake::Task["app:bootstrap:samples:armors"].execute(nil)
      Rake::Task["app:bootstrap:samples:potions"].execute(nil)
      Rake::Task["app:bootstrap:samples:property_types"].execute(nil)
      Rake::Task["app:bootstrap:samples:missions"].execute(nil)
    end

    namespace :samples do
      desc "Bootstrap item groups"
      task :item_groups => :environment do
        %w{Weapons Armors Potions}.each do |name|
          ItemGroup.create(:name => name)
        end
      end

      desc "Bootstrap missions"
      task :missions => :environment do
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
            :experience     => 1,
            :money_min      => 8,
            :money_max      => 15,
            :ep_cost        => 1,
            :payouts        => Payouts::Collection.new(
              Payouts::Item.new(Item.find_by_name("Wooden Shield"), :apply_on => :complete)
            )
          }
        }

        @missions.each_pair do |key, value|
          puts "Adding mission '#{key}'"

          Mission.find_or_create_by_name(key).update_attributes(
            value.reverse_merge(
              :requirements => Requirements::Collection.new,
              :payouts      => Payouts::Collection.new
            )
          )
        end
      end

      desc "Bootstrap weapons"
      task :weapons => :environment do
        @weapons = {
          "Knife" => {
            :level => 1,
            :description => "",
            :basic_price => 40,
            :effects => Effects::Collection.new(Effects::Attack.new(1)),
            :image => img("weapon_knife"),
            :placements => "left_hand,right_hand"
          },
          "Cloud Poleaxe" => {
            :level => 5,
            :description => "",
            :basic_price => 1000,
            :vip_price => 5,
            :effects => Effects::Collection.new(Effects::Attack.new(13), Effects::Defence.new(5)),
            :image => img("weapon_cloud_poleaxe"),
            :placements => "left_hand,right_hand"
          }
        }

        @group = ItemGroup.find_by_name("Weapons")

        @weapons.each_pair do |key, value|
          puts "Adding weapon '#{key}'"

          Item.find_or_create_by_name(key).update_attributes(
            value.merge(:item_group => @group)
          )
        end
      end

      desc "Bootstrap armors"
      task :armors => :environment do
        @armors = {
          "Wooden Shield" => {
            :level        => 1,
            :description  => "",
            :basic_price  => 70,
            :effects      => Effects::Collection.new(Effects::Defence.new(1)),
            :placements   => "left_hand,right_hand",
            :image        => img("armor_wooden_shield")
          }
        }

        @group = ItemGroup.find_by_name("Armors")

        @armors.each_pair do |key, value|
          puts "Adding armor '#{key}'"

          Item.find_or_create_by_name(key).update_attributes(
            value.merge(:item_group => @group)
          )
        end
      end

      desc "Bootstrap potions"
      task :potions => :environment do
        @potions = {
          "Small Potion of Healing" => {
            :level        => 1,
            :description  => "Small potion of magic healing liquor. Heals up to 20 health points.",
            :basic_price  => 50,
            :usable       => true,
            :usage_limit  => 1,
            :effects      => Effects::Collection.new(Effects::RestoreHealth.new(20)),
            :image        => img("potion_of_healing")
          },
          "Small Potion of Refresh" => {
            :level        => 1,
            :description  => "Small potion of refreshing liquor. Heals up to 5 energy points.",
            :basic_price  => 10,
            :vip_price    => 1,
            :usable       => true,
            :usage_limit  => 1,
            :effects      => Effects::Collection.new(Effects::RestoreEnergy.new(5)),
            :image        => img("potion_of_energy")
          },
          "Small Potion of Upgrade" => {
            :level        => 1,
            :description  => "Small potion of magic power liquor. Gives you 5 upgrade points.",
            :basic_price  => 50,
            :vip_price    => 5,
            :usable       => true,
            :usage_limit  => 1,
            :effects      => Effects::Collection.new(Effects::Upgrade.new(5)),
            :image        => img("potion_of_upgrade")
          }
        }

        @group = ItemGroup.find_by_name("Potions")

        @potions.each_pair do |key, value|
          puts "Adding potion '#{key}'"

          Item.find_or_create_by_name(key).update_attributes(
            value.merge(:item_group => @group)
          )
        end
      end

      desc "Create property types"
      task :property_types => :environment do
        @property_types = {
          "Mill" => {
            :description  => "Small mill near town",
            :level        => 1,
            :basic_price  => 500,
            :image        => img("property_mill"),
            :money_min    => 5,
            :money_max    => 20
          }
        }

        @property_types.each_pair do |key, value|
          puts "Adding property type '#{key}'"

          PropertyType.find_or_create_by_name(key).update_attributes(value)
        end
      end
    end
  end
end