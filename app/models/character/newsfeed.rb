class Character
  module Newsfeed
    def self.included(base)
      base.class_eval do
        has_many :news, :class_name => "News::Base", :extend => AssociationExtension
      end
    end

    module AssociationExtension
      def add(news_type, data)
        begin
          news_klass = News.const_get(news_type.to_s.classify)
          news_klass.create(:character => proxy_owner, :data => data)
        rescue NameError # passed news_type is not correct
          proxy_owner.news.create(:data => data)
        end
      end
    end
  end  
end
