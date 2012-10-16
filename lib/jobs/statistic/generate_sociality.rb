module Jobs
  module Statistic
    class GenerateSociality
      def perform
        puts "Generating statistics: sociality by reference..."

        statistic = Statistics::Sociality.new
        reference_types = statistic.reference_types

        reference_types.each do |name, users_count|
          data = {
            :name             => name,
            :users_amount     => users_count,
            :friends_amount   => statistic.average_friends_by_reference(name),
            :friends_in_game  => statistic.average_in_game_friends_by_reference(name),
            :referrers_amount => statistic.average_referrers_by_reference(name)
          }

          $redis.hset("sociality_by_reference_#{Time.new.strftime("%Y-%m-%d")}", name, Marshal.dump(data))
        end

        puts "Done!"
      end
    end
  end
end