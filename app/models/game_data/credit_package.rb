module GameData
  class CreditPackage < Base
    class << self
      def load!
        Dir[Rails.root.join('db/data/credit_packages.rb')].each do |file|
          eval File.read(file)
        end
      end
    end

    attr_accessor :vip_money, :price
  end
end