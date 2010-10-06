class Character
  module Collections
    def self.included(base)
      base.class_eval do
        has_many :collection_ranks,
          :class_name => "ItemCollectionRank"

        has_many :collections,
          :class_name => "ItemCollection",
          :through    => :collection_ranks,
          :extend     => AssociationExtension
      end
    end

    module AssociationExtension
      def apply!(collection)
        rank = proxy_owner.collection_ranks.find_by_collection_id(collection.id) 
        rank ||= proxy_owner.collection_ranks.build(:collection => collection)

        rank.apply!
        
        rank
      end
    end
  end
end