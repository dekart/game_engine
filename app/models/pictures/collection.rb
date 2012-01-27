module Pictures
  module Collection
    def urls
      $memory_store.fetch(picture_url_cache_key) do
        load_target unless loaded?

        if proxy_target.empty?
          {}
        else
          {}.tap do |result|
            proxy_owner.picture_options[:styles].each do |style, value|
              picture = proxy_target.find{|p| p.style == style.to_s } || build(:style => style)

              result[style] = picture.image.url
            end

            default = proxy_target.find{|p| p.style == default_style } || build(:style => nil)
            result[nil] = default.image.url
          end
        end
      end
    end

    def url(style = nil)
      urls[style]
    end

    def picture_url_cache_key
      "#{ proxy_owner.cache_key }/picture_urls"
    end

    def default_style
      proxy_owner.picture_options[:styles].first.try(:first).try(:to_s)
    end

    def sort_by_style
      load_target unless loaded?

      sorted = [].tap do |result|
        proxy_owner.picture_options[:styles].each do |style, value|
          if picture = proxy_target.find{|p| p.style == style.to_s }
            result << picture
          end
        end
      end

      sorted += proxy_target.find_all{|p| p.style.blank? }
    end
  end
end
