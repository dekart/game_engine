require Rails.root.join('lib', 'httperf_report.rb')
include HttperfReport

namespace :app do
  namespace :performance do
    desc "Check app performance"
    task :check => :environment do
      puts "Running httperf..."

      httperf_report do |r|
        #r.cookies :signed_request => 'asdasd'

        r.group 'Mission List' do |g|
          100.times do
            g.get '/mission_groups'
          end
        end

        r.group 'Mission Group Switch' do |g|
          100.times do |i|
            g.get "/mission_groups/#{(i % 2) + 1}"
          end
        end

        r.group 'Opponent List' do |g|
          100.times do
            g.get "/fights/new"
          end
        end

        r.group 'Purchase Item' do |g|
          100.times do
            g.post '/inventories', :item_id => 123
          end
        end
      end

      puts "Done"
    end
  end
end
