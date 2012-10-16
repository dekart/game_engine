module Jobs
  module Statistic
    class GenerateSociality
      def perform
        puts "Generating statistics: sociality by reference..."

        statistic = Statistics::Sociality.new
        reference_types = statistic.reference_types

        data = [].tap do |result|
          reference_types.each do |name, users_count|
            result << {
              :name             => name,
              :users_amount     => users_count,
              :friends_amount   => statistic.average_friends_by_reference(name),
              :friends_in_game  => statistic.average_in_game_friends_by_reference(name),
              :referrers_amount => statistic.average_referrers_by_reference(name)
            }
          end
        end

        $redis.set("sociality_by_reference_#{Time.new.strftime("%Y-%m-%d")}", Marshal.dump(data))

        puts "Done!"
      end
    end
  end
end