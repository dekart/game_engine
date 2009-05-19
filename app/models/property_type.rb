class PropertyType < ActiveRecord::Base
  has_attached_file :image,
    :styles => {
      :icon   => "40x40#",
      :small  => "120x>"
    }
end
