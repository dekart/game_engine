class ConvertContentToDsl < ActiveRecord::Migration
  def up
    FileUtils.mkdir_p(Rails.root.join('config/locales/data'))

    announce "Converting item groups..."

    group_names = {}

    File.open(Rails.root.join('db/data/item_groups.rb'), 'w+') do |dsl|
      ItemGroup.without_state(:deleted).order(:position).each do |group|
        key = group.name.parameterize.underscore

        FileUtils.mkdir_p(Rails.root.join("db/data/items/#{ key }"))

        tags = []
        tags << :shop if group.display_in_shop

        group_names[key] = group.name

        code = %{
          GameData::ItemGroup.define :#{ key } do |g|
            g.tags = #{ tags.inspect }
          end
        }

        if group.hidden?
          dsl.puts %{
            if false # It's hidden
              #{code}
            end
          }
        else
          dsl.puts code
        end
      end
    end

    File.open(Rails.root.join('config/locales/data/item_groups.yml'), 'w+') do |locale|
      locale.puts YAML.dump({'en' => {'data' => {'item_groups' => group_names}}})
    end


    announce 'Converting items...'

    FileUtils.mkdir_p(Rails.root.join('db/data/items'))

    item_locale = {}

    Item.without_state(:deleted).joins(:item_group).each do |item|
      key = item.alias

      tags = []
      tags << :shop if item.availability == :shop
      tags << :gift if item.availability == :gift
      tags << :market if item.can_be_sold_on_market
      tags << :exchange if item.exchangeable

      code = ''

      code << %{
        i.level = #{item.level}
      } if item.level > 1

      code << %{
        i.placements = #{ item.placements.inspect }
      } unless item.placements.empty?

      code << %{
        i.basic_price = #{item.basic_price}
      } if item.basic_price > 0

      code << %{
        i.vip_price = #{item.vip_price}
      } if item.vip_price > 0

      code << %{
        i.package_size = #{item.package_size}
      } if item.package_size

      code << %{
        i.sell_price = #{item.sell_price}
      } if item.can_be_sold?

      code << %{
        i.max_market_price = #{ item.max_vip_price_in_market }
      } if item.max_vip_price_in_market.to_i > 0

      code << %{
        i.boost = :#{item.boost_type}
      } if item.boost_type.present?

      unless item.effects.empty?
        effects = {}

        item.effects.each do |e|
          effects[e.name.to_sym] = e.value
        end

        code << %{
          i.effects = #{ effects.inspect }
        }
      end

      code << payouts_to_dsl('i', item.payouts, :use)

      File.open(Rails.root.join("db/data/items/#{item.item_group.name.parameterize.underscore}/#{key}.rb#{ '.hidden' if item.hidden? }"), 'w+') do |dsl|
        dsl.puts %{
          GameData::Item.define :#{key} do |i|
            i.group = :#{ item.item_group.name.parameterize.underscore }

            i.tags = #{ tags.inspect }
            #{code}
          end
        }
      end

      item_locale[key] = {
        'name' => {
          'one' => item.name,
          'many' => item.plural_name
        },
        'description' => item.description,
        'use' => {
          'button' => item.use_button_label,
          'message' => item.use_message
        }.reject{|k,v| v.blank? }
      }.reject{|k,v| v.blank? }
    end

    File.open(Rails.root.join('config/locales/data/items.yml'), 'w+') do |locale|
      locale.puts YAML.dump('en' => {'data' => {'items' => item_locale}})
    end


    announce 'Converting item sets...'

    File.open(Rails.root.join('db/data/item_sets.rb'), 'w+') do |dsl|
      ItemSet.all.each do |set|
        key = set.name.parameterize.underscore

        items = set.items.map{|i, c| ":#{ i.alias } => #{c}" }

        dsl.puts %{
          GameData::ItemSet.define :#{ key } do |g|
            g.items = {
              #{ items.join(",\n") }
            }
          end
        }
      end
    end


    announce 'Converting item collections...'

    FileUtils.mkdir_p(Rails.root.join('db/data/item_collections'))

    collection_names = {}

    ItemCollection.without_state(:deleted).each do |collection|
      key = collection.name.parameterize.underscore

      collection_names[key] = collection.name

      code = ''

      code << %{
        c.level = #{collection.level}
      } if collection.level > 1

      code << %{
        c.items = {
          %s
        }
      } % collection.items.map do |item|
        ":#{item.alias} => #{collection.amount_of_item(item)}"
      end.join(",\n")

      code << payouts_to_dsl('c', collection.payouts, :collected)
      code << payouts_to_dsl('c', collection.payouts, :repeat_collected)

      File.open(Rails.root.join("db/data/item_collections/#{key}.rb#{ '.hidden' if collection.hidden? }"), 'w+') do |dsl|
        dsl.puts %{
          GameData::ItemCollection.define :#{ key } do |c|
            #{code}
          end
        }
      end
    end

    File.open(Rails.root.join('config/locales/data/item_collections.yml'), 'w+') do |locale|
      locale.puts YAML.dump('en' => {'data' => {'item_collections' => collection_names}})
    end


    announce 'Converting achievement types...'

    FileUtils.mkdir_p(Rails.root.join('db/data/achievements'))

    achievement_locale = {}

    AchievementType.without_state(:deleted).each do |achievement|
      key = achievement.name.parameterize.underscore

      achievement_locale[key] = {
        'name' => achievement.name,
        'description' => achievement.description
      }.reject{|k,v| v.blank? }

      code = ''

      code << %{
        a.condition do |character|
          character.#{achievement.key} >= #{achievement.value}
        end
      }

      code << payouts_to_dsl('a', achievement.payouts, :achieve)

      File.open(Rails.root.join("db/data/achievements/#{key}.rb#{ '.hidden' if achievement.hidden? }"), 'w+') do |dsl|
        dsl.puts %{
          GameData::Achievement.define :#{ key } do |a|
            #{code}
          end
        }
      end
    end

    File.open(Rails.root.join('config/locales/data/achievements.yml'), 'w+') do |locale|
      locale.puts YAML.dump('en' => {'data' => {'achievements' => achievement_locale}})
    end


    announce 'Converting credit packages...'

    File.open(Rails.root.join("db/data/credit_packages.rb"), 'w+') do |dsl|
      CreditPackage.without_state(:deleted).each do |package|
        code = ''

        code << %{
          p.tags = [:default]
        } if package.default

        code << %{
          p.vip_money = #{package.vip_money}
        }
        code << %{
          p.price = #{package.price}
        }

        code = %{
          GameData::CreditPackage.define :package_#{ package.id } do |c|
            #{code}
          end
        }

        if package.hidden?
          dsl.puts %{
            if false # It's hidden
              #{code}
            end
          }
        else
          dsl.puts code
        end
      end
    end


    announce 'Converting mission groups...'

    group_names = {}

    File.open(Rails.root.join('db/data/mission_groups.rb'), 'w+') do |dsl|
      MissionGroup.without_state(:deleted).order(:position).each do |group|
        key = group.name.parameterize.underscore

        FileUtils.mkdir_p(Rails.root.join("db/data/missions/#{ key }"))

        tags = []
        tags << :hide_unsatisfied if group.hide_unsatisfied

        group_names[key] = group.name

        code = ''

        code << %{
          g.tags = #{ tags.inspect }
        } unless tags.empty?

        [:success, :failure, :repeat_success, :repeat_failure, :level_complete, :mission_complete, :mission_group_complete].each do |t|
          code << payouts_to_dsl('g', group.payouts, t)
        end

        code << requirements_to_dsl('g', group.requirements)

        code = %{
          GameData::MissionGroup.define :#{ key } do |g|
            #{code}
          end
        }

        if group.hidden?
          dsl.puts %{
            if false # It's hidden
              #{code}
            end
          }
        else
          dsl.puts code
        end
      end
    end

    File.open(Rails.root.join('config/locales/data/mission_groups.yml'), 'w+') do |locale|
      locale.puts YAML.dump({'en' => {'data' => {'mission_groups' => group_names}}})
    end


    announce 'Converting missions...'

    mission_locale = {}

    Mission.without_state(:deleted).joins(:mission_group).order('mission_groups.position, missions.position').each do |mission|
      key = mission.name.parameterize.underscore
      group_key = mission.mission_group.name.parameterize.underscore

      mission_locale[key] = {
        'name' => mission.name,
        'description' => mission.description,
        'success' => mission.success_text,
        'failure' => mission.failure_text,
        'complete' => mission.complete_text,
        'button' => mission.button_label
      }.reject{|k,v| v.blank? }

      code = %{
        m.group = :#{ group_key }
      }

      tags = []
      tags << :repeatable if mission.repeatable
      tags << :hide_unsatisfied if mission.hide_unsatisfied

      code << %{
        m.tags = #{ tags.inspect }
      } unless tags.empty?

      code << requirements_to_dsl('m', mission.requirements)

      [:success, :failure, :repeat_success, :repeat_failure, :level_complete, :mission_complete].each do |t|
        code << payouts_to_dsl('m', mission.payouts, t)
      end

      mission.levels.order(:position).each do |level|
        code << %{
          m.level do |l|
            l.steps = #{level.win_amount}
        }

        code << %{
          l.chance = #{level.chance}
        } if level.chance < 100

        code << requirements_to_dsl('l', level.requirements) do
          %{
            r.ep #{level.energy}
          }
        end

        [:success, :repeat_success].each do |t|
          code << payouts_to_dsl('l', level.payouts, t) do
            %{
              r.take_energy #{level.energy}
              r.give_experience #{level.experience}
              r.give_basic_money #{level.money_min}..#{level.money_max}
            }
          end
        end

        [:failure, :repeat_failure].each do |t|
          code << payouts_to_dsl('l', level.payouts, t) do
            %{
              r.take_energy #{level.energy}
            }
          end
        end

        code << payouts_to_dsl('m', mission.payouts, :level_complete)

        code << %{
          end
        }
      end

      File.open(Rails.root.join("db/data/missions/#{group_key}/#{key}.rb#{ '.hidden' if mission.hidden? }"), 'w+') do |dsl|
        dsl.puts %{
          GameData::Mission.define :#{ key } do |m|
            #{code}
          end
        }
      end
    end

    File.open(Rails.root.join('config/locales/data/missions.yml'), 'w+') do |locale|
      locale.puts YAML.dump('en' => {'data' => {'missions' => mission_locale}})
    end


    announce 'Converting monsters...'

    FileUtils.mkdir_p(Rails.root.join('db/data/monsters'))

    monster_locale = {}

    MonsterType.without_state(:deleted).each do |monster|
      key = monster.name.parameterize.underscore

      monster_locale[key] = {
        'name' => monster.name,
        'description' => monster.description
      }.reject{|k,v| v.blank? }

      code = ''

      tags = []
      tags << :multiplayer if monster.available_for_friends_invite

      code << %{
        m.tags = #{ tags.inspect }
      } unless tags.empty?
      code << %{
        m.level = #{monster.level}
      } if monster.level > 1

      code << %{
        m.fight_time = #{monster.fight_time}.hours
        m.respawn_time = #{monster.respawn_time}.hours

        m.health = #{monster.health}

        m.damage = #{monster.minimum_damage}..#{monster.maximum_damage}
        m.response = #{monster.minimum_response}..#{monster.maximum_response}

        m.reward_collectors = #{monster.number_of_maximum_reward_collectors}
      }

      unless monster.effects.empty?
        effects = {}

        monster.effects.each do |e|
          effects[e.name.to_sym] = e.value
        end

        code << %{
          m.effects = #{ effects.inspect }
        }
      end

      [:victory, :repeat_victory, :fight_start, :invite].each do |t|
        code << payouts_to_dsl('m', monster.payouts, t)
      end

      code << payouts_to_dsl('m', monster.payouts, :attack) do
        %{
          r.give_experience #{monster.experience}
          r.give_basic_money #{monster.money}
        }
      end

      code << requirements_to_dsl('m', monster.requirements)

      File.open(Rails.root.join("db/data/monsters/#{key}.rb#{ '.hidden' if monster.hidden? }"), 'w+') do |dsl|
        dsl.puts %{
          GameData::MonsterType.define :#{ key } do |m|
            #{code}
          end
        }
      end
    end

    File.open(Rails.root.join('config/locales/data/monsters.yml'), 'w+') do |locale|
      locale.puts YAML.dump('en' => {'data' => {'monsters' => monster_locale}})
    end

    #property_type
    #character_type

    #setting
    #story
    ##tip
    #translation
    #contest
    #help_page

    say 'Done!'
  end

  def down
  end

  def payouts_to_dsl(variable, payouts, trigger, &block)
    code = ''
    preview_code = ""
    preview_required = false

    payouts.find_all(trigger).each do |payout|
      instruction = case payout
        when Payouts::AttackPointsTotal
          if payout.action == :add
            %{r.increase_attribute(:attack, #{payout.value})}
          else
            %{r.decrease_attribute(:attack, #{payout.value})}
          end
        when Payouts::BasicMoney
          if payout.action == :add
            %{r.give_basic_money(#{payout.value})}
          else
            %{r.take_basic_money(#{payout.value})}
          end
        when Payouts::DefencePointsTotal
          if payout.action == :add
            %{r.increase_attribute(:defence, #{payout.value})}
          else
            %{r.decrease_attribute(:defence, #{payout.value})}
          end
        when Payouts::EnergyPoint
          if payout.action == :add
            %{r.give_energy(#{payout.value}#{ ', true' if payout.can_exceed_maximum })}
          else
            %{r.take_energy(#{payout.value})}
          end
        when Payouts::EnergyPointsTotal
          if payout.action == :add
            %{r.increase_attribute(:energy, #{payout.value})}
          else
            %{r.decrease_attribute(:energy, #{payout.value})}
          end
        when Payouts::Experience
          %{r.give_experience(#{payout.value})}
        when Payouts::HealthPoint
          if payout.action == :add
            %{r.give_health(#{payout.value}#{ ', true' if payout.can_exceed_maximum })}
          else
            %{r.take_health(#{payout.value})}
          end
        when Payouts::HealthPointsTotal
          if payout.action == :add
            %{r.increase_attribute(:health, #{payout.value})}
          else
            %{r.decrease_attribute(:health, #{payout.value})}
          end
        when Payouts::Item
          if payout.action == :add
            %{r.give_item(:#{payout.item.alias}, #{payout.amount})}
          else
            %{r.take_item(:#{payout.item.alias}, #{payout.amount})}
          end
        when Payouts::Mercenary
          if payout.action == :add
            %{r.give_mercenaries(#{payout.value})}
          else
            %{r.take_mercenaries(#{payout.value})}
          end
        when Payouts::StaminaPoint
          if payout.action == :add
            %{r.give_stamina(#{payout.value}#{ ', true' if payout.can_exceed_maximum })}
          else
            %{r.take_stamina(#{payout.value})}
          end
        when Payouts::StaminaPointsTotal
          if payout.action == :add
            %{r.increase_attribute(:stamina, #{payout.value})}
          else
            %{r.decrease_attribute(:stamina, #{payout.value})}
          end
        when Payouts::UpgradePoint
          if payout.action == :add
            %{r.give_upgrade_points(#{payout.value})}
          else
            %{r.take_upgrade_points(#{payout.value})}
          end
        when Payouts::VipMoney
          if payout.action == :add
            %{r.give_vip_money(#{payout.value})}
          else
            %{r.take_vip_money(#{payout.value})}
          end
        when Payouts::RandomItem
          if payout.action == :add
            %{r.give_random_item(:#{ payout.item_set.name.parameterize.underscore }#{', true' if payout.shift_item_set})}
          else
            %{r.take_random_item(:#{ payout.item_set.name.parameterize.underscore }#{', true' if payout.shift_item_set})}
          end
        end

      code << instruction

      if payout.chance < 100
        code << %{ if Dice.chance(#{payout.chance}) }
        preview_required = true
      end

      code << "\n"

      preview_code << instruction
      preview_code << "\n"
    end

    custom_code = block_given? ? yield : ''

    code << custom_code
    preview_code << custom_code

    return '' if code.blank?

    code = %{
      #{variable}.reward_on :#{trigger} do |r|
        #{code}
      end
    }

    code << %{
      #{variable}.reward_preview_on :#{trigger} do |r|
        #{preview_code}
      end
    } if preview_required

    code
  end

  def requirements_to_dsl(variable, requirements, &block)
    code = ''

    requirements.each do |requirement|
      case requirement
        when Requirements::Alliance
          code << "r.alliance_size #{ requirement.value }"
        when Requirements::Attack
          code << "r.attack #{ requirement.value }"
        when Requirements::BasicMoney
          code << "r.basic_money #{ requirement.value }"
        when Requirements::CharacterType
          code << "r.character_type :#{ requirement.character_type.name.parameterize.underscore }"
        when Requirements::Defence
          code << "r.defence #{ requirement.value }"
        when Requirements::EnergyPoint
          code << "r.ep #{ requirement.value }"
        when Requirements::HealthPoint
          code << "r.hp #{ requirement.value }"
        when Requirements::Item
          code << "r.item :#{ requirement.item.alias }#{ ', ' + requirement.amount.to_s if requirement.amount > 1 }"
        when Requirements::Level
          code << "r.level #{ requirement.value }"
        when Requirements::Property
          code << "r.property :#{ requirement.property_type.name.parameterize.underscore }"
        when Requirements::StaminaPoint
          code << "r.sp #{ requirement.value }"
        when Requirements::VipMoney
          code << "r.vip_money #{ requirement.value }"
        end

      code << "\n"
    end

    code << (block_given? ? yield : '')

    return '' if code.blank?

    %{
      #{variable}.requires do |r|
        #{code}
      end
    }
  end
end
