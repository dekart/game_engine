require 'factory_girl'

Factory.define :user do |t|
  t.facebook_id 123456789
  
  t.access_token 'abc123'
  t.access_token_expire_at 1.hour.from_now
end

Factory.define :character_type do |t|
  t.name "Character Type"
  t.description "This is our test character type"

  t.basic_money 0
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
  
  t.association :user
  t.association :character_type
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

Factory.define :visibility do |t|
  t.association :target, :factory => :item
  t.association :character_type
end

Factory.define :item_group do |t|
  t.name            'first'
end

Factory.define :item do |t|
  t.association   :item_group

  t.name          'Fake Item'
  t.availability  'shop'
  t.level         1

  t.basic_price   10

  t.usable  true
  t.payouts Payouts::Collection.new(
    Payouts::BasicMoney.new(:value => 100, :apply_on => :use)
  )

  t.placements [:additional]
end

Factory.define :inventory do |t|
  t.association :character
  t.association :item
  
  t.amount 1
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

Factory.define :monster_type do |t|
  t.name 'The Monster'
  t.description 'The fake monster'

  t.requirements Requirements::Collection.new(
    Requirements::Level.new(:value => 1)
  )

  t.payouts Payouts::Collection.new(
    Payouts::BasicMoney.new(:value => 123, :apply_on => :victory),
    Payouts::BasicMoney.new(:value => 456, :apply_on => :repeat_victory)
  )

  t.attack 10
  t.defence 10

  t.minimum_damage 3
  t.maximum_damage 10
  t.minimum_response 1
  t.maximum_response 5

  t.experience 5
  t.money 5

  t.health 1000

  t.state 'visible'
end

Factory.define :monster do |t|
  t.association :monster_type
  t.association :character
end

Factory.define :monster_fight do |t|
  t.association :monster
  t.association :character

  t.damage 1
end

Factory.define :mission_group do |t|
  t.name "Some Group"

  t.state 'visible'
end

Factory.define :mission do |t|
  t.association :mission_group

  t.name "Some Mission"
  t.success_text "Success!"
  t.complete_text "Complete!"

  t.state 'visible'
end

Factory.define :mission_level do |t|
  t.association :mission
  
  t.win_amount 5
  t.energy 5
  t.experience 5
  t.money_min 10
  t.money_max 20
  t.chance 50
end

Factory.define :mission_with_level, :parent => :mission do |t|
  t.after_create do |m|
    m.levels << Factory(:mission_level, :mission => m)
  end
end

Factory.define :gift do |t|
  t.association :character
  t.association :item
end

Factory.define :gift_receipt do |t|
  t.association :gift

  t.facebook_id 987654321
end

Factory.define :item_set do |t|
  t.name 'Fake Item Set'
  t.item_ids do
    item1 = Factory(:item)
    item2 = Factory(:item)

    "[[#{item1.id}, 70], [#{item2.id}, 30]]"
  end
end

Factory.define :boss do |t|
  t.association :mission_group

  t.name 'Fake Boss'
  t.health 100
  t.attack 1
  t.defence 1
  t.ep_cost 5
  t.experience 10
  
  t.state 'visible'
end

Factory.define :wall_post do |t|
  t.association :character
  t.association :author, :factory => :character

  t.text "This is a Fake Text"
end

Factory.define :story do |t|
  t.alias 'fake_story'
  
  t.title 'This is the fake story'
  t.description 'This is description'
  t.action_link 'Play our app!'
end