module Jobs
  module Statistic
    class GeneratePayments
      def perform
        puts "Generating statistics: payments by reference..."

        statistic = Statistics::Payments.new
        reference_types = statistic.reference_types

        reference_types.each do |name, users_count, paying_count|
          data = [users_count, paying_count, statistic.total_payments_by_reference(name)].join(",")

          $redis.hset("payment_by_reference_#{Time.new.strftime("%Y-%m-%d")}", name, data)
        end

        puts "Done!"
      end
    end
  end
end