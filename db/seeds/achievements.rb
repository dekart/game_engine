AchievementType.create!(
  :key => 'total_money',
  :value => 500,
  :name => 'Beggar',
  :description => 'Earn 500 coins',

  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 1, :apply_on => :achieve, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg"))
  }]
)

AchievementType.create!(
  :key => 'total_money',
  :value => 2000,
  :name => 'Merchant',
  :description => 'Earn 2.000 coins',

  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 2, :apply_on => :achieve, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg"))
  }]
)

AchievementType.create!(
  :key => 'total_money',
  :value => 10000,
  :name => 'Lord',
  :description => 'Earn 10.000 coins',

  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 3, :apply_on => :achieve, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg"))
  }]
)

AchievementType.create!(
  :key => 'total_money',
  :value => 100000,
  :name => 'Duke',
  :description => 'Earn 100.000 coins',

  :payouts => Payouts::Collection.new(
    Payouts::VipMoney.new(:value => 4, :apply_on => :achieve, :visible => true)
  ),

  :picture_attributes     => [{
    :image => File.open(Rails.root.join("db", "pictures", "achievement.jpg"))
  }]
)
