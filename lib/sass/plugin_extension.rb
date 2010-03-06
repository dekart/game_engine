module Sass
  module Plugin
    def self.update_stylesheets
      return if options[:never_update]

      Asset.update_sass
      Skin.update_sass

      super
    end
  end
end