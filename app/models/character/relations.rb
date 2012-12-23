class Character
  module Relations
    def self.included(base)
      base.class_eval do
        has_many :relations,
          :foreign_key  => "owner_id",
          :order        => "type, relations.created_at DESC",
          :extend       => RelationsAssociationExtension
        has_many :friend_relations,
          :foreign_key  => "owner_id",
          :include      => :character,
          :dependent    => :destroy,
          :extend       => FriendRelationsAssociationExtension
        has_many :mercenary_relations,
          :foreign_key  => "owner_id",
          :dependent    => :delete_all,
          :extend       => MercenaryRelationsAssociationExtension,
          :autosave     => true
      end
    end

    def alliance_size
      relations.effective_size
    end

    module RelationsAssociationExtension
      def effective_size
        maximum_size? ? Setting.i(:relation_max_alliance_size) : size + 1
      end

      def maximum_size?
        size + 1 >= Setting.i(:relation_max_alliance_size)
      end
    end

    module FriendRelationsAssociationExtension
      def establish!(target)
        transaction do
          create(:character => target)
          target.friend_relations.create(:character => proxy_association.owner)
        end
      end

      def character_ids
        all(:select => "character_id").collect{|r| r[:character_id] }
      end

      def facebook_ids
        all(:include => {:character => :user}).collect{|r|
          r.character.user.facebook_id
        }
      end

      def with(character)
        first(:conditions => {:character_id => character.id})
      end

      def established?(character)
        !with(character).nil?
      end

      def random
        first(:offset => rand(size)) if size > 0
      end
    end

    module MercenaryRelationsAssociationExtension
      def random
        first(:offset => rand(size)) if size > 0
      end
    end
  end
end
