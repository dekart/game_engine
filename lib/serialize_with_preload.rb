module SerializeWithPreload
  def self.extended(base)
    base.class_eval do
      class << self
        alias_method_chain :serialize, :preload
      end
    end
  end

  def serialize_with_preload(*args)
    Dir[File.join(RAILS_ROOT, "app", "models", "{effects,payouts,requirements}", "*.rb")].each do |file|
      require file
    end

    serialize_without_preload(*args)
  end
end
