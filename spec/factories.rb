require 'factory_girl'

Factory.define :character_type do |t|
  t.name "Character Type"
  t.description "This is our test character type"

  t.basic_money 1100
  t.vip_money   1

  t.attack      1
  t.defence     1
  
  t.health      100
  t.energy      10
  t.stamina     10

  t.points      0
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

  t.state "visible"
end

Factory.define :property do |t|
  t.association :property_type, :factory => :property_type
end

Factory.define :stuff_invisibility do |t|
  t.association :stuff, :factory => :item
  t.association :character_type
end

Factory.define :item do |t|
  t.name          'item'
  t.availability  'shop'
  t.level         1
  t.association   :item_group

  t.usable  true
  t.payouts Payouts::Collection.new(
    Payouts::BasicMoney.new(:value => 100, :apply_on => :use)
  )
end

Factory.define :item_group do |t|
  t.name            'first'
end

Factory.define :hit_listing do |t|
  t.client {|c| 
    c.association :character, Factory.attributes_for(:character).merge(:basic_money => 10_000)
  }
  t.victim {|v|
    v.association :character
  }

  t.reward 10_000
end