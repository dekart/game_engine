AchievementType.create!(
  :key => 'total_money',
  :value => 100,
  :name => 'Beggar',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 1, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 1000,
  :name => 'Merchant',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 2, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 10000,
  :name => 'Lord',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 3, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 100000,
  :name => 'Duke',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 4, :apply_on => :achieve, :visible => true)
  )
)