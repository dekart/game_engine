module Jobs
  class ProcessPayments < Struct.new(:payment_ids)
    def perform
      payment_ids.each do |id|
        payment = CreditOrder.where(facebook_id: id).first_or_initialize

        payment.check_completion_status
      end
    end
  end
end