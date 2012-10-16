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

        data = [].tap do |result|
          reference_types.each do |name, users_count|
            result << {
              :name            => name,
              :users_amount    => users_count,
              :returned_amount => returned[name] || 0,
              :level_2         => reached_level_2[name] || 0,
              :level_5         => reached_level_5[name] || 0,
              :level_20        => reached_level_20[name] || 0
            }
          end
        end

        $redis.set("retention_by_reference_#{Time.new.strftime("%Y-%m-%d")}", Marshal.dump(data))

        puts "Done!"
      end
    end
  end
end