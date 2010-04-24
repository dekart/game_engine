puts "Seeding properties..."

mill = PropertyType.create!(
  :name         => "Windmill",
  :level        => 1,
  :basic_price  => 3000,
  :income       => 5,
  :inflation    => 200,
  :image        => File.open(Rails.root.join("db", "pictures", "mill.jpg"))
)
