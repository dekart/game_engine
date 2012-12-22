class UpdateContestImageStyles < ActiveRecord::Migration
  def change
    Contest.transaction do
      Contest.find_each do |c|
        if old_picture = c.pictures.first
          c.picture_attributes = [{
            :style => :promo,
            :image => old_picture.image.to_file
          }]

          c.save

          old_picture.destroy
        end
      end
    end
  end
end
