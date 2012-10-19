module Jobs
  module Statistic
    class GeneratePayments
      def perform
        puts "Generating statistics: payments by reference..."

        statistic = Statistics::Payments.new
        reference_types = statistic.reference_types

        data = [].tap do |result|
          reference_types.each do |name, users_count, paying_count|
            result << {
              :name            => name,
              :users_amount    => users_count,
              :paying_amount   => paying_count,
              :payments_amount => statistic.total_payments_by_reference(name)
            }
          end
        end

        $redis.set("payment_by_reference_#{Time.new.strftime("%Y-%m-%d")}", Marshal.dump(data))

        puts "Done!"
      end
    end
  end
end