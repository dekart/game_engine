require 'factory_girl'

Factory.define :character_type do |t|
  t.name "Character Type"
  t.description "This is our test character type"

  t.basic_money 1100
  t.vip_money   1
end

Factory.define :character do |t|
  t.name "Character"
  t.association :character_type, :factory => :character_type
end

Factory.define :property_type do |t|
  t.name        "Property Type"
  t.plural_name "Property Types"
  t.description "This our test property type"

  t.image_file_name     "property.jpg"
  t.image_content_type  "image/jpeg"
  t.image_file_size     100.kilobytes

  t.availability "shop"

  t.level 1

  t.basic_price 1000
  t.vip_price   1

  t.upgrade_cost_increase 100

  t.income 10
  t.collect_period 5

  t.state "visible"
end