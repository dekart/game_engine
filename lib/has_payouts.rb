module HasPayouts
  def has_payouts(*args)
    preload_payouts

    serialize :payouts, Payouts::Collection

    send(:include, InstanceMethods)

    options = args.extract_options!

    options.reverse_merge!(
      :default_event => args.first
    )

    cattr_accessor :payout_events
    self.payout_events  = args

    cattr_accessor :payout_options
    self.payout_options = options
  end

  def preload_payouts
    Dir[File.join(RAILS_ROOT, "app", "models", "payouts", "*.rb")].each do |file|
      file.gsub(File.join(RAILS_ROOT, "app", "models"), "").gsub(".rb", "").classify.constantize
    end
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