require Rails.root.join('lib', 'httperf_report.rb')

namespace :app do
  namespace :performance do
    desc "Check app performance"
    task :check => :environment do

      def generate_item(item_group, level, placement)
        Item.create(
          :name => "item#{Time.now.to_i}",
          :item_group => item_group,
          :level => level,
          :availability => "shop",
          :basic_price => 1,
          :placements => placement,
          :state => "visible")
      end

      def generate_inventory(character, item)
        Inventory.create(
          :character => character,
          :item => item,
          :amount => 1)
      end

      def generate_collection(items)
        ItemCollection.create(
          :name => "collection#{Time.now.to_i}",
          :item_ids => items.collect{|i| i.id}.join(","),
          :state => "visible")
      end

      def generate_property_type
        PropertyType.create(
          :name => "property#{Time.now.to_i}",
          :level => 1,
          :availability => "shop",
          :basic_price => 1,
          :income => 1,
          :state => "visible")
      end

      def generate_monster_type
        MonsterType.create(
          :name => "property#{Time.now.to_i}",
          :level => 1,
          :health => 1, :attack => 1, :defence => 1,
          :experience => 1, :money => 1,
          :fight_time => 20,
          :minimum_damage => 1, :maximum_damage => 2,
          :minimum_response => 1, :maximum_response => 2,
          :state => "visible")
      end

      character = Character.first
      item_group = ItemGroup.first

      httperf_report do |r|
        r.params :signed_request => "o2Z6o5kMgGGr9jm7fxPLnwxOYLC_OSujeTc3mte34eE.eyJleHBpcmVzIjoxMzAxNTY1NjAwLCJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsInVzZXJfaWQiOjEwOTYyOTM0MDYsIm9hdXRoX3Rva2VuIjoiMTk4NjEwMjgzNDkxMzUxfDIubEpYUG1EQ18zc0ZuRXA3cE5iNVVXQV9fLjM2MDAuMTYxNzE3OTQzMy0xMDk2MjkzNDA2fFFTb0VRZEpsaVYyWGlmS21mNnNHSTlnaWxCUSIsInVzZXIiOnsibG9jYWxlIjoicnVfUlUifSwiaXNzdWVkX2F0IjoxMzAxNTU5MDQwfQ"

        r.group 'Main page' do |g|
          100.times do
            g.get '/'
          end
        end

        r.group 'Mission List' do |g|
          100.times do
            g.get '/mission_groups'
          end
        end

        r.group 'Mission Group Switch' do |g|
          100.times do |i|
            mission_group = [character.mission_groups.first, character.mission_groups.current][i % 2]

            g.get "/mission_groups/#{mission_group.id}"
          end
        end

        r.group 'Mission fullfill' do |g|
          100.times do
            mission = character.missions.first

            g.post "/missions/#{mission.id}/fulfill"
          end
        end
        
        r.group 'Browse Shop' do |g|
          100.times do |i|
            g.get "/items"
          end
        end

        r.group 'Purchase Item' do |g|
          100.times do |i|
            item = generate_item(item_group, 1, 'head')
            
            g.post '/inventories', :item_id => item.id
          end
        end

        r.group 'Inventories' do |g|
          100.times do |i|
            g.get "/inventories"
          end
        end

        r.group 'Equipment page' do |g|
          100.times do
            g.get '/inventories/equipment'
          end
        end

        r.group 'Equip best' do |g|
          100.times do
            g.post "/inventories/equip"
          end
        end

        r.group 'Equip item' do |g|
          inventories = []
          2.times do |i|
            item = generate_item(item_group, 1, 'head')
            inventories << generate_inventory(character, item)
          end

          100.times do |i|
            g.post "/inventories/#{inventories[i % 2].id}/equip", :placement => 'head'
          end
        end

        r.group 'Item Collections' do |g|
          100.times do
            g.get '/item_collections'
          end
        end

        r.group 'Apply Collection' do |g|
          100.times do
            items = []
            2.times do
              items << item = generate_item(item_group, 1, 'head')
              generate_inventory(character, item)
            end

            item_collection = generate_collection(items)

            g.put "/item_collections/#{item_collection.id}"
          end
        end

        r.group 'Opponent List' do |g|
          100.times do
            g.get "/fights/new"
          end
        end

        r.group 'Fight' do |g|
          100.times do
            character2 = character.possible_victims[0] || Character.last

            g.post '/fights', :victim_id => character2.id
          end
        end

        r.group 'Alliance Page' do |g|
          100.times do
            g.get '/relations'
          end
        end

        r.group 'Bank Deposit' do |g|
          100.times do
            g.post '/bank_operations/deposit', :amount => 300, :character_id => character.id
          end
        end

        r.group 'Bank Withdraw' do |g|
          100.times do
            g.post '/bank_operations/withdraw', :amount => 30, :character_id => character.id
          end
        end

        r.group 'Properties Page' do |g|
          100.times do
            g.get '/properties'
          end
        end

        r.group 'Properties Collection' do |g|
          100.times do
            g.get '/properties/collect_money'
          end
        end

        r.group 'Purchase Property' do |g|
          100.times do
            property_type = generate_property_type()

            g.post '/properties', :property_type_id => property_type.id
          end
        end

        r.group 'Special Items' do |g|
          100.times do
            g.get '/premium'
          end
        end

        r.group 'Purchase Special Item' do |g|
          100.times do
            g.put '/premium', :type => 'refill_health'
          end
        end

        r.group 'Gifts List' do |g|
          100.times do
            g.get '/gifts/new'
          end
        end

        r.group 'Hit Listing' do |g|
          100.times do
            g.get '/hit_listings'
          end
        end

        r.group 'Market Items' do |g|
          100.times do
            g.get '/market_items'
          end
        end

        r.group 'Monster List' do |g|
          100.times do
            g.get '/monsters'
          end
        end

        r.group 'Start Monster Fight' do |g|
          100.times do
            monster_type = generate_monster_type()

            g.get "/monsters/new", :monster_type_id => monster_type.id
          end
        end

        r.group 'Requests' do |g|
          100.times do
            g.get '/app_requests'
          end
        end
      end

      puts "Done"
    end
  end
end
