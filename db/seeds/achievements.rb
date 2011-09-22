AchievementType.create!(
  :key => 'total_money',
  :value => 100,
  :name => 'Beggar',
  :description => 'Earn 100 coins',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 1, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 1000,
  :name => 'Merchant',
  :description => 'Earn 1.000 coins',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 2, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 10000,
  :name => 'Lord',
  :description => 'Earn 10.000 coins',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 3, :apply_on => :achieve, :visible => true)
  )
)

AchievementType.create!(
  :key => 'total_money',
  :value => 100000,
  :name => 'Duke',
  :description => 'Earn 100.000 coins',
  :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg")),
  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 4, :apply_on => :achieve, :visible => true)
  )
)