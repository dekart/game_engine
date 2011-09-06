puts "Seeding properties..."

mill = PropertyType.create!(
  :name         => "Windmill",
  :level        => 1,
  :image        => File.open(Rails.root.join("db", "pictures", "mill.jpg")),
  :basic_price  => 200,
  :income       => 5,
  
  :upgrade_cost_increase  => 100
)
