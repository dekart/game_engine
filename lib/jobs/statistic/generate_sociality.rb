module Jobs
  module Statistic
    class GenerateSociality
      def perform
        puts "Generating statistics: sociality by reference..."

        statistic = Statistics::Sociality.new
        reference_types = statistic.reference_types

        reference_types.each do |name, users_count|
          data = [
              users_count, 
              statistic.average_friends_by_reference(name),
              statistic.average_in_game_friends_by_reference(name),
              statistic.average_referrers_by_reference(name)
            ].join(",")

          $redis.hset("sociality_by_reference_#{Time.new.strftime("%Y-%m-%d")}", name, data)
        end

        puts "Done!"
      end
    end
  end
end