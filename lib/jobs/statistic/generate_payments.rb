module Jobs
  module Statistic
    class GeneratePayments
      def perform
        puts "Generating statistics: payments by reference..."

        statistic = Statistics::Payments.new
        reference_types = statistic.reference_types

        reference_types.each do |name, users_count, paying_count|
          data = {
            :name            => name,
            :users_amount    => users_count,
            :paying_amount   => paying_count,
            :payments_amount => statistic.total_payments_by_reference(name)
          }

          $redis.hset("payment_by_reference_#{Time.new.strftime("%Y-%m-%d")}", name, Marshal.dump(data))
        end

        puts "Done!"
      end
    end
  end
end