ActiveRecord::Base.transaction do
  %w{settings assets items missions monsters properties tips character_types achievements credit_packages}.each do |section|
    require File.expand_path("../seeds/#{section}", __FILE__)
  end
end

puts "Publishing seeded data..."

ActiveRecord::Base.transaction do
  [MissionGroup, Mission, MonsterType, ItemGroup, Item, PropertyType, CharacterType, Tip, AchievementType, CreditPackage].each do |model|
    model.all.each do |record|
      record.publish
    end
  end
end

puts "Seed complete!"