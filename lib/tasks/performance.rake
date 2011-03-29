require Rails.root.join('lib', 'httperf_report.rb')
include HttperfReport

namespace :app do
  namespace :performance do
    desc "Check app performance"
    task :check => :environment do

      httperf_report do |r|
        r.params :signed_request => "i0eaFEt4NqkgjV6PlFgK16FnT4YWU100GkltdXzCU7Owg.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImV4cGlyZXMiOjEzMDEzNzg0MDAsImlzc3VlZF9hdCI6MTMwMTM3NDcwOSwib100F1dGhfdG9rZW4iOiIxOTg100MTAyODM0OTEzNTF8Mi40S0Q5dVhHOWlocW1MTWkzR09wZFJnX18uMzYwMC4xMzAxMzc4NDAwLTEwOTYyOTM0MDZ8dTdudWl6eklDb0hIRVZUVGVTaW9STTRsYkF3IiwidXNlciI6eyJjb3VudHJ5IjoicnUiLCJsb100NhbGUiOiJydV9SVSIsImFnZSI6eyJtaW4iOjIxfX0sInVzZXJfaWQiOiIxMDk100MjkzNDA100In0"

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
            g.get "/mission_groups/#{(i % 100) + 1}"
          end
        end

        r.group 'Mission fullfill' do |g|
          item = Mission.last
          100.times do
            g.post "/missions/#{item.nil? ? 1: item.id}/fulfill"
          end
        end
        
        r.group 'Browse Shop' do |g|
          100.times do |i|
            g.get "/items"
          end
        end

        r.group 'Purchase Item' do |g|
          item = Item.with_state(:visible).available.last
          100.times do
            g.post '/inventories', :item_id => item.nil? ? 1 : item.id
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
          item = Item.last
          100.times do
            g.post "/inventories/#{item.nil? ? 1: item.id}/equip", :placement => 'head'
          end
        end

        r.group 'Item Collections' do |g|
          100.times do
            g.get '/item_collections'
          end
        end

        r.group 'Apply Collection' do |g|
          item = ItemCollection.last
          100.times do
            g.put "/item_collections/#{item.nil? ? 1: item.id}"
          end
        end

        r.group 'Opponent List' do |g|
          100.times do
            g.get "/fights/new"
          end
        end

        r.group 'Fight' do |g|
          item = Character.last
          100.times do
            g.post '/fights', :victim_id => item.nil? ? 1 : item.id
          end
        end

        r.group 'Alliance Page' do |g|
          100.times do
            g.get '/relations'
          end
        end

        r.group 'Bank Deposit' do |g|
          item = Character.last
          100.times do
            g.post '/bank_operations/deposit', :amount => 10000,  :character_id => item.nil? ? 1: item.id
          end
        end

        r.group 'Bank Withdraw' do |g|
          item = Character.last
          100.times do
            g.post '/bank_operations/withdraw', :amount => 1000,   :character_id => item.nil? ? 1: item.id
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
          item = PropertyType.last
          100.times do
            g.post '/properties', :property_type_id => item.nil? ? 1: item.id
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

        r.group 'Purchase Market Item' do |g|
          item = MarketItem.last
          100.times do
            g.post "/market_items/#{item.nil? ? 1: item.id}/buy"
          end
        end

        r.group 'Monster List' do |g|
          100.times do
            g.get '/monsters'
          end
        end

        r.group 'Start Monster Fight' do |g|
          item = MonsterType.last
          100.times do
            g.get "/monsters/new", :monster_type_id => item.nil? ? 1: item.id
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
