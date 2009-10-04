module HasPayouts
  def has_payouts
    Dir[File.join(RAILS_ROOT, "app", "models", "payouts", "*.rb")].each do |file|
      file.gsub(File.join(RAILS_ROOT, "app", "models"), "").gsub(".rb", "").classify.constantize
    end

    serialize :payouts, Payouts::Collection

    send(:include, InstanceMethods)
  end

  module InstanceMethods
    def payouts
      super || Payouts::Collection.new
    end

    def payouts=(collection)
      if collection and !collection.is_a?(Payouts::Collection)
        items = collection.values.collect do |payout|
          Payouts::Base.by_name(payout[:type]).new(payout.except(:type))
        end

        collection = Payouts::Collection.new(*items)
      end

      super(collection)
    end
  end
end