namespace :app do
  namespace :export do
    desc "Export items in CSV format"
    task :items, [:folder_path] => :environment do |task, options|
      require 'csv'
      
      File.open(File.join(options.folder_path, "items.csv"), 'w+') do |file|
        image_folder = File.join(options.folder_path, "items")
        FileUtils.mkdir_p(image_folder)
        
        current_group = nil
        
        file.puts CSV.generate_line(
          [
            "Item Group", 
            "Name",
            "Description", 
            "Image",
            "Level", 
            "Availability", 
            "Basic Price", 
            "Vip Price", 
            "Attack", 
            "Defence", 
            "Health", 
            "Energy", 
            "Stamina", 
            "Can be sold", 
            "Market", 
            "Max VIP Price", 
            "Exchangeable", 
            "Placement"
          ]
        )
        
        file.puts CSV.generate_line([])
        
        ItemGroup.without_state(:deleted).each do |group|
          unless group == current_group
            file.puts CSV.generate_line([group.name] + Array.new(15))
          end
          
          group.items.without_state(:deleted).each do |item|
            if item.image?
              image_name = "%04d%s" % [item.id, File.extname(item.image_file_name)]
              
              FileUtils.cp(item.image.to_file.path, File.join(image_folder, image_name))
            else
              image_name = nil
            end
            
            file.puts CSV.generate_line(
              [ 
                nil, # group name
                item.name,
                item.description,
                image_name,
                item.level,
                item.availability,
                (item.basic_price unless item.basic_price == 0),
                (item.vip_price unless item.vip_price == 0),
                (item.attack unless item.attack == 0),
                (item.defence unless item.defence == 0),
                (item.health unless item.health == 0),
                (item.energy unless item.energy == 0),
                (item.stamina unless item.stamina == 0),
                ("yes" if item.can_be_sold),
                ("yes" if item.can_be_sold_on_market),
                item.max_vip_price_in_market,
                ("yes" if item.exchangeable),
                item.placements.join(',')
              ]
            )
          end
        end
      end
    end
  end
end