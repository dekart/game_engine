namespace :app do
  namespace :pictures do
    desc "Save original images to temporary folder"
    task :transfer => :environment do
      [AchievementType, CharacterType, Contest, CreditPackage, Item, 
       MissionGroup, Mission, MonsterType, PropertyType, Story].each do |klass|
        klass.has_attached_file :image

        puts "Generating pictures for #{klass.to_s} (#{ klass.count } objects)..."

        klass.find_each(:batch_size => 100) do |obj|
          if obj.image?
            file = obj.image.to_file 

            obj.picture_attributes = [{
                :image => file, 
                :style => obj.pictures.default_style
            }]

            obj.save

            print "."
            $stdout.flush
          end
        end

        puts
      end
    end
  end
end
