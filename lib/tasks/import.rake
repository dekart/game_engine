namespace :app do
  namespace :import do
    desc "Import missions and mission groups"
    task :missions, :file_path, :needs => :environment do |t, options|
      require 'csv'
      
      if File.file?(options.file_path)
        data = CSV.parse(File.read(options.file_path))
        
        data.shift(2) # Skipping header rows
        
        current_group = nil
        current_mission = nil
        
        Mission.transaction do
          data.each do |row|
            next if row.compact.empty?
            
            group_name, group_level,
            mission_name, mission_description,
            win_amount, money_min, money_max, energy, experience = row
          
            if group_name.present? # Mission Group
              current_group = MissionGroup.new(
                :name => group_name
              )
              
              if group_level.to_i > 0
                current_group.requirements = Requirements::Collection.new(
                  Requirements::Level.new(:value => group_level)
                )
              end
              
              current_group.save!
              current_group.publish!
            elsif mission_name.present? # Mission
              current_mission = current_group.missions.build(
                :name => mission_name,
                :description => mission_description
              )
              
              current_mission.save!
              current_mission.publish!
            elsif win_amount.to_i > 0 # MissionLevel
              level = current_mission.levels.build(
                :win_amount => win_amount,
                :money_min  => money_min,
                :money_max  => money_max,
                :energy     => energy,
                :experience => experience
              )
              
              level.save!
            end
          end
        end
      else
        puts "File not found: #{ options.file_path }"
      end
    end
  
    desc "Import items and item groups"
    task :items, :file_path, :needs => :environment do |t, options|
      require 'csv'
      
      if File.file?(options.file_path)
        data = CSV.parse(File.read(options.file_path))
        
        data.shift(2) # Skipping header rows
        
        current_group = nil
        
        Item.transaction do
          data.each do |row|
            next if row.compact.empty?

            group_name, 
            name, description, level, availability, basic_price, vip_price, 
            attack, defence, energy, stamina, can_be_sold, market, max_vip_price, exchangeable, placements = row
          
            if group_name.present?
              current_group = ItemGroup.new(
                :name => group_name
              )
            
              current_group.save!
              current_group.publish!
            elsif name.present?
              item = current_group.items.build(
                :name         => name, 
                :description  => description.to_s,
                :level        => level || 1,
                :availability => availability.downcase,
                :basic_price  => basic_price,
                :vip_price    => vip_price,
                :attack       => attack,
                :defence      => defence,
                :energy       => energy,
                :stamina      => stamina,
                :can_be_sold  => (can_be_sold && can_be_sold.downcase == 'yes'),
                :can_be_sold_on_market    => (market && market.downcase == 'yes'),
                :max_vip_price_in_market  => max_vip_price,
                :exchangeable => (exchangeable && exchangeable.downcase == 'yes'),
                :placements   => placements ? placements.split(/[\s,]+/).map{|p| p.downcase.underscore.to_sym } : nil
              )
            
              item.save!
              item.publish!
            end
          end
        end
      end
    end
  end
end