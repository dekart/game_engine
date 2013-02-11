require 'factory_girl'

Factory.define :user do |t|
  t.facebook_id 123456789

  t.access_token 'abc123'
  t.access_token_expire_at 1.day.from_now
end

Factory.define :user_with_character, :parent => :user do |t|
  t.after_create do |u|
    Factory(:character, :user => u)
  end
end

Factory.define :user_with_email, :parent => :user do |t|
  t.email "test@test.com"
end

Factory.define :character do |t|
  t.name "Character"

  t.character_type GameData::CharacterType.collection.values.first
  t.association :user
end
