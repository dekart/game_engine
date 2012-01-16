module HasPictures
  def has_pictures(*args)
    options = args.empty? ? {:styles => []} : args.extract_options!

    cattr_accessor :picture_options
    self.picture_options = options

    has_many :pictures,
      :as       => :owner,
      :autosave => true,
      :extend   => Pictures::Collection

    send(:include, InstanceMethods)

    before_save :create_missing_picture_styles
  end

  def picture_styles_for_select
    picture_options[:styles].collect{|name, value| [name.to_s.humanize, name.to_s] }
  end

  module InstanceMethods
    def picture_attributes
      pictures.map{|p| p.attributes }
    end

    def picture_attributes=(collection)
      collection = collection.values if collection.is_a?(Hash)

      collection.each do |attributes|
        attributes.symbolize_keys!

        picture_id = attributes.delete(:id)
        remove     = attributes.delete(:_destroy)
        image      = attributes.delete(:image)

        if picture_id && !picture_id.blank?
          picture = pictures.detect{|p| p.id == picture_id.to_i }
        elsif !image.blank?
          picture = pictures.build
        end

        if picture
          if remove.blank?
            attributes[:style] ||= pictures.default_style

            picture.attributes = attributes
            picture.image      = image unless image.blank?
          else
            picture.mark_for_destruction unless picture.new_record?
          end
        end
      end

      id_will_change! unless new_record? # Force object to save with timestamp update
    end

    def pictures?
      !pictures.urls.empty?
    end

    def create_missing_picture_styles
      return unless Picture.table_exists? # This is necessary to make avoid fail of migrations operating with objects when the table is not created yet

      missing_styles = picture_options[:styles].collect{|name, value| name } -
                       pictures.reject{|p| p.marked_for_destruction? }.collect{|p| p.style.try(:to_sym) }

      if missing_styles.any? and pictures.any?
        original = pictures.sort_by_style.first

        missing_styles.each do |style|
          picture = pictures.build(:style => style)
          picture.image = original.image.to_file
        end
      end

      true
    end
  end
end
