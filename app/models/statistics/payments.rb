class Statistics
  class Payments < self
    def reference_types
      result = User.all(
        :select => "reference, count(*) as total_amount, sum(paying) as paying_amount",
        :group  => :reference,
        :order  => :reference
      )

      result.collect!{|d| [d[:reference], d[:total_amount].to_i, d[:paying_amount].to_i] }

      result
    end

    def total_payments_by_reference(reference)
      character_ids = Character.joins(:user).where("users.reference = ?", reference).collect{|c| c.id }

      result = VipMoneyDeposit.purchases.all(
          :select => "count(*) as total_amount",
          :conditions => ["character_id IN (?)", character_ids]
        )

      result.collect{|d| d[:total_amount].to_i}.first
    end
  end
end