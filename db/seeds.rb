ActiveRecord::Base.transaction do
  %w{settings items missions monsters properties character_types achievements credit_packages help_pages item_collections}.each do |section|
    require File.expand_path("../seeds/#{section}", __FILE__)
  end
end

puts "Publishing seeded data..."

ActiveRecord::Base.transaction do
  [MissionGroup, Mission, MonsterType, ItemGroup, Item, PropertyType, CharacterType, AchievementType, CreditPackage, HelpPage, ItemCollection].each do |model|
    model.all.each do |record|
      record.publish
    end
  end
end

puts "Seed complete!"