module Jobs
  module Statistic
    class GenerateRetention
      def perform
        puts "Generating statistics: retention by reference..."

        statistic = Statistics::Retention.new
        reference_types = statistic.reference_types

        returned = statistic.returned_users
        reached_level_2  = statistic.users_reached_level(2)
        reached_level_5  = statistic.users_reached_level(5)
        reached_level_20 = statistic.users_reached_level(20)

        reference_types.each do |name, users_count|
          data = [users_count, returned[name], reached_level_2[name], reached_level_5[name], reached_level_20[name]].join(",")

          $redis.hset("retention_by_reference_#{Time.new.strftime("%Y-%m-%d")}", name, data)
        end

        puts "Done!"
      end
    end
  end
end