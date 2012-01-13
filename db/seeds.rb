ActiveRecord::Base.transaction do
  %w{settings assets items missions monsters properties tips character_types achievements credit_packages help_pages}.each do |section|
    require File.expand_path("../seeds/#{section}", __FILE__)
  end
end

puts "Publishing seeded data..."

ActiveRecord::Base.transaction do
  [MissionGroup, Mission, MonsterType, ItemGroup, Item, Boss, PropertyType, CharacterType, Tip, AchievementType, CreditPackage, HelpPage].each do |model|
    model.all.each do |record|
      record.publish
    end
  end
end

puts "Seed complete!"