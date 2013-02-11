class Character
  class Equipment
    module Inventories
      class Collection
        attr_accessor :character, :inventories

        delegate :<<, :shift, :unshift, :each, :empty?, :any?, :size, :first, :last, :[], :detect, :include?, :sum, :push, :group_by, :sort_by, :to => :inventories

        class << self
          def dump(collection)
            Yajl::Encoder.encode(collection.inventories.collect{|inventory| inventory.to_attr_hash })
          end

          def load(data)
            inventories = begin
              if !data.blank? && array = Yajl::Parser.parse(data)
                array.map{ |entry| Inventories::Inventory.new(entry.symbolize_keys) }
              else
                []
              end
            rescue Yajl::ParseError
              []
            end

            new(nil, inventories)
          end
        end

        def initialize(character = nil, inventories = [])
          @character   = character
          @inventories = inventories
        end

        def save
          character.equipment.inventories = self
          character.equipment.save
        end

        #items
        def items
          ids = inventories.collect{|inventory| inventory.item_id }.uniq

          Item.where({:id => ids })
        end

        def equipped_items
          ids = inventories.select{|inventory| inventory.equipped? }.collect{|inventory| inventory.item_id }.uniq

          Item.where({:id => ids })
        end

        def count(item)
          find_by_item(item).try(:amount).to_i
        end

        # scopes
        def find_by_item(item)
          inventories.detect{|inventory| inventory.item_id == item.id }
        end

        def find_by_item_id(item_id)
          inventories.detect{|inventory| inventory.item_id == item_id.to_i }
        end

        def by_item_ids(item_ids)
          inventories.find_all do |inventory|
            item_ids.include?(inventory.item_id)
          end
        end

        def equippable
          item_ids = items.equippable.collect{ |item| item.id }

          by_item_ids(item_ids).select{|inventory| inventory.amount_available_for_equipment > 0 }
        end

        def exchangeable
          item_ids = items.exchangeable.collect{ |item| item.id }

          by_item_ids(item_ids)
        end

        def equipped
          inventories.select{ |inventory| inventory.equipped? }
        end

        def by_item_group(group)
          item_ids = items.where(:item_group_id => group.id).
            order("items.level ASC, items.basic_price ASC").
            collect{|item| item.id }

          by_item_ids(item_ids)
        end

        def by_item_collection(collection)
          by_item_ids(collection.item_ids)
        end

        def usable_with_payout(name)
          usable_item_ids = items.find_all{ |item| item.payouts.payout_include?(name) }.collect{ |item| item.id }

          by_item_ids(usable_item_ids)
        end

        def boosts
          boost_item_ids = items.boosts.collect{ |item| item.id }

          by_item_ids(boost_item_ids)
        end

        def by_boost_type(boost_type)
          boost_item_ids = items.boosts(boost_type.to_s).collect{ |item| item.id }

          by_item_ids(boost_item_ids)
        end

        # operations
        def give!(item, amount = 1)
          inventory = give(item, amount)

          Character::Equipment.transaction do
            if save
              item.increment_owned(amount)

              equip!(item)

              inventory = find_by_item(item)
              check_item_collections(inventory)
            end
          end

          inventory
        end

        def take!(item, amount = 1)
          inventory = take(item, amount)

          Character::Equipment.transaction do
            if save
              item.increment_owned(-amount)

              unequip!(item)

              check_exchanges(item)
              check_market_items(item)
            end
          end

          inventory
        end

        def sell!(item, amount = 1)
          effective_amount = count(item)
          effective_amount = amount if effective_amount > amount

          if effective_amount > 0
            inventory = take(item, effective_amount)

            character.charge(- item.sell_price * effective_amount, 0, item)

            ActiveSupport::Notifications.instrument(:sell_item,
              :item         => item,
              :basic_money  => item.sell_price * effective_amount
            )

            Character::Equipment.transaction do
              if save and character.save
                item.increment_owned(-effective_amount)

                unequip!(item)

                check_exchanges(item)
                check_market_items(item)
              end
            end
          end

          find_by_item(item)
        end

        def transfer!(character, item, amount = 1)
          raise ArgumentError.new('Cannot transfer negative amount of items') if amount < 1
          raise ArgumentError.new('Source character doesn\'t have enough items') if find_by_item(item).amount < amount

          Character::Equipment.transaction do
            take!(item, amount)
            character.inventories.give!(item, amount)
          end
        end

        def to_s
          "#<Inventories::Collection #{inventories}>"
        end

        protected
          def give(item, amount = 1)
            amount = amount.to_i

            if inventory = find_by_item(item)
              inventory.amount += amount
            else
              inventory = Inventory.new(
                :item_id => item.id,
                :amount  => amount
              )

              inventories.push(inventory)
            end

            inventory
          end

          def take(item, amount = 1)
            amount = amount.to_i

            if inventory = find_by_item(item)
              if inventory.amount > amount
                inventory.amount -= amount
              else
                amount = inventory.amount

                self.inventories -= [inventory]
              end

              inventory
            else
              false
            end
          end

          def check_item_collections(inventory)
            if item_ids = ItemCollection.used_item_ids[inventory.item_id]
              item_ids.each do |collection_id, amount_for_collection|
                if inventory.amount >= amount_for_collection
                  collection = ItemCollection.find(collection_id)

                  collection_inventories = by_item_collection(collection).select{|inv| collection.enough_of?(inv)}

                  if collection_inventories.size == collection.item_ids.size
                    character.notifications.schedule(:items_collection,
                      :collection_id => collection.id
                    )

                    break
                  end
                end
              end
            end
          end

          def check_market_items(item)
            if item.can_be_sold_on_market? and market_item = character.market_items.find_by_item_id(item) and
                market_item.amount > count(item)

              market_item.destroy unless market_item.destroyed?
            end
          end

          def check_exchanges(item)
            if item.exchangeable?
              ExchangeOffer.destroy_created_by_character_for_item(character, item)
              Exchange.invalidate_created_by_character_for_item(character, item)
            end
          end

          def equip!(item)
            return unless item.equippable?

            if Setting.b(:character_auto_equipment)
              character.equipment.equip_best!(true)
            else
              character.equipment.auto_equip!(item)
            end
          end

          def unequip!(item)
            return unless item.equippable?

            if Setting.b(:character_auto_equipment)
              character.equipment.equip_best!(true)
            else
              character.equipment.auto_unequip!(item)
            end
          end
      end
    end
  end
end