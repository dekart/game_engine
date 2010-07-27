class Statistics
  class VipMoney < self
    def total_deposit
      VipMoneyDeposit.sum(:amount)
    end

    def total_withdraw
      VipMoneyWithdrawal.sum(:amount)
    end

    def deposit_by_period
      VipMoneyDeposit.scoped(:conditions => ["created_at > ?", @period.ago]).sum(:amount)
    end

    def withdraw_by_period
      VipMoneyWithdrawal.scoped(:conditions => ["created_at > ?", @period.ago]).sum(:amount)
    end

    def deposit_reference_types
      reference_types_by_class(VipMoneyDeposit)
    end

    def withdraw_reference_types
      reference_types_by_class(VipMoneyWithdrawal)
    end

    def popular_deposit_references
      popular_references_by_class(VipMoneyDeposit)
    end

    def popular_withdraw_references
      popular_references_by_class(VipMoneyWithdrawal)
    end

    protected

    def reference_types_by_class(klass)
      totals = klass.all(
        :select => "reference_type, sum(amount) as total_amount",
        :group  => :reference_type,
        :order  => :reference_type
      )

      totals.collect!{|d| [d[:reference_type], d[:total_amount].to_i] }

      by_period = klass.scoped(:conditions => ["created_at > ?", @period.ago]).all(
        :select => "reference_type, sum(amount) as total_amount",
        :group  => :reference_type,
        :order  => :reference_type
      )

      by_period.collect!{|d| [d[:reference_type], d[:total_amount].to_i] }

      result = totals.collect do |name, count|
        [name.to_s.humanize, count, by_period.assoc(name).try(:last).to_i]
      end

      result.sort!{|a, b| b.last <=> a.last }
      
      result
    end

    def popular_references_by_class(klass)
      totals = klass.all(
        :select => "reference_id, reference_type, sum(amount) as total_amount",
        :group  => "reference_id, reference_type"
      )

      totals.collect!{|d| [d.reference, d[:total_amount].to_i]}

      by_period = klass.scoped(:conditions => ["created_at > ?", @period.ago]).all(
        :select => "reference_id, reference_type, sum(amount) as total_amount",
        :group  => "reference_id, reference_type"
      )

      by_period.collect!{|d| [d.reference, d[:total_amount].to_i]}

      result = totals.collect do |reference, count|
        [reference, count, by_period.assoc(reference).try(:last).to_i]
      end

      result.sort!{|a, b| b.last <=> a.last }
      
      result
    end
  end
end