def img(name)
  File.open(File.join(RAILS_ROOT, "db", "pictures", "#{name}.jpg"))
end

namespace :app do
  namespace :bootstrap do
    desc "Bootstrap assets"
    task :assets => :environment do
      image_folder = File.join(RAILS_ROOT, "public", "images")

      Dir[File.join(image_folder, "**", "*")].each do |file_name|
        if File.file?(file_name)
          Asset.create(
            :alias => file_name.sub(image_folder + "/", "").sub(File.extname(file_name), "").gsub("/", "_"),
            :image => File.open(file_name)
          )
        end
      end
    end
  end
end