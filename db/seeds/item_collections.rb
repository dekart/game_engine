puts "Seeding collections..."

ItemCollection.create!(
  :name => "Sample Collection",

  :item_ids => Item.all(:limit => 4).map(&:id),

  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 5, :apply_on => [:collected]),
    Payouts::Experience.new(:value => 50, :apply_on => [:collected, :repeat_collected])
  )
)