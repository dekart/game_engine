class Statistics
  class VipMoney < self
    def default_scope
      @time_range ? VipMoneyOperation.where(["vip_money_operations.created_at BETWEEN ? AND ?", @time_range.begin, @time_range.end]) : VipMoneyOperation
    end
    
    def scope_by_class(klass)
      scope.where(:type => klass.sti_name)
    end
    
    def total_deposit
      scope_by_class(VipMoneyDeposit).sum(:amount)
    end

    def total_withdrawal
      scope_by_class(VipMoneyWithdrawal).sum(:amount)
    end

    def deposit_reference_types
      reference_types_by_class(VipMoneyDeposit)
    end

    def withdrawal_reference_types
      reference_types_by_class(VipMoneyWithdrawal)
    end

    def popular_deposit_references
      popular_references_by_class(VipMoneyDeposit)
    end

    def popular_withdrawal_references
      popular_references_by_class(VipMoneyWithdrawal)
    end

    protected

    def reference_types_by_class(klass)
      totals = scope_by_class(klass).all(
        :select => "reference_type, sum(amount) as total_amount",
        :group  => :reference_type,
        :order  => :reference_type
      )

      totals.collect!{|d| [d[:reference_type], d[:total_amount].to_i] }

      by_period = scope_by_class(klass).where(:created_at => @time_range).all(
        :select => "reference_type, sum(amount) as total_amount",
        :group  => :reference_type,
        :order  => :reference_type
      )

      by_period.collect!{|d| [d[:reference_type], d[:total_amount].to_i] }

      result = totals.collect do |name, count|
        [name.to_s, count, by_period.assoc(name).try(:last).to_i]
      end

      result.sort!{|a, b| b.last <=> a.last }

      result
    end

    def popular_references_by_class(klass)
      totals = scope_by_class(klass).all(
        :select => "reference_id, reference_type, sum(amount) as total_amount",
        :group  => "reference_id, reference_type"
      )

      totals.collect!{|d| [d.reference, d[:total_amount].to_i]}

      by_period = scope_by_class(klass).where(:created_at => @time_range).all(
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
