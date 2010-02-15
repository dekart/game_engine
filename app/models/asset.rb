class Asset < ActiveRecord::Base
  has_attached_file :image, :styles => {:small => "100x100>"}

  validates_presence_of :alias
  validates_uniqueness_of :alias
  validates_format_of :alias, :with => /^[a-z_0-9]+$/, :allow_blank => true

  after_save :update_stylesheet_template
  after_destroy :update_stylesheet_template

  class << self
    def [](value)
      logger.silence do
        find_by_alias(value.to_s)
      end
    end
  end
  
  protected

  def update_stylesheet_template
    File.open(Rails.root.join("public", "stylesheets", "sass", "_assets.sass"), "w+") do |file|
      Asset.all.each do |asset|
        file.puts "!asset_#{asset.alias} = url(\"#{asset.image.url}\")"
      end
    end
  end
end
