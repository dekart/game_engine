class Property < ActiveRecord::Base
  belongs_to :character
  belongs_to :property_type

  delegate :name, :plural_name, :description, :pictures, :pictures?, :basic_price, :vip_price,
    :income, :collect_period, :payouts, :income_by_level, :worker_names,
    :to => :property_type

  attr_accessor :charge_money

  after_save :assign_collected_at, :if => :active?

  def maximum_level
    property_type.upgrade_limit || Setting.i(:property_upgrade_limit)
  end

  def upgrade_price
    property_type.upgrade_price(level)
  end

  def upgradeable?
    active? and level < maximum_level
  end

  def collectable?
    active? and collected_at < Time.now - collect_period.hours
  end

  def total_income
    income_by_level == 0 ? income * level : income + income_by_level * (level - 1)
  end

  def time_to_next_collection
    collectable? ? 0 : (collected_at + collect_period.hours).to_i - Time.now.to_i
  end

  def active?
    !missing_workers?
  end

  def missing_workers
    property_type.workers.to_i > 0 ? property_type.workers.to_i - workers : 0
  end

  def missing_workers?
    missing_workers > 0
  end

  def worker_friends
    ids = worker_friend_ids

    Character.find(ids).sort_by{|c| ids.index(c.id) }
  end

  def worker_friend_ids
    self[:worker_friend_ids].split(',').map{|id| id.to_i }
  end

  def worker_friend_ids=(value)
    self[:worker_friend_ids] = Array.wrap(value).join(',')
  end

  def add_worker!(character)
    return if missing_workers == 0 || worker_friend_ids.include?(character.id)

    self.worker_friend_ids += [character.id]
    self.workers += 1

    save!
  end

  def hire_worker!(hire_all = nil)
    return if missing_workers == 0

    workers_to_hire = hire_all.present? ? missing_workers : 1

    total_price = workers_to_hire * Setting.i(:property_worker_price)

    if character.vip_money < total_price
      Requirements::Collection.new(
        Requirements::VipMoney.new(:value => total_price)
      )
    else
      transaction do
        self.workers += workers_to_hire

        save!

        character.charge!(0, total_price, property_type)
      end

      workers_to_hire
    end
  end

  def buy!
    if valid? && purchase_requirements_satisfied?
      transaction do
        result = payouts.apply(character, :build, property_type)

        if save! && character.charge!(basic_price, vip_price, property_type)
          character.news.add(:property_purchase, :property_id => id)

          result
        else
          false
        end
      end
    else
      false
    end
  end

  def upgrade!
    return false if new_record?

    unless upgradeable?
      errors.add(:character, :too_much_properties, :plural_name => plural_name)

      return false
    end

    if upgrade_requirements_satisfied?
      transaction do
        increment(:level)

        result = payouts.apply(character, :upgrade, property_type)

        save(:validate => false) && character.charge!(property_type.upgrade_price(level - 1), vip_price, property_type)

        character.news.add(:property_upgrade, :property_id => id, :level => level)

        result
      end
    else
      false
    end
  end

  def collect_money!
    if collectable?
      transaction do
        update_attribute(:collected_at, Time.now)

        result = payouts.apply(character, :collect, property_type)

        result << Payouts::BasicMoney.new(:value => total_income)

        character.charge!(- total_income, 0, self)

        character.news.add(:property_collect, :property_id => id)

        result
      end
    else
      false
    end
  end

  def upgrade_requirements
    @upgrade_requirements ||= Requirements::Collection.new.tap do |r|
      r << Requirements::BasicMoney.new(:value => upgrade_price) if upgrade_price > 0
      r << Requirements::VipMoney.new(:value => vip_price) if vip_price > 0
    end
  end

  def purchase_requirements
    property_type.requirements + property_type.default_requirements
  end

  def as_json(*args)
    {
      :name => name
    }
  end

  protected

    def upgrade_requirements_satisfied?
      if @requirements_satisfied.nil?
        @requirements_satisfied = upgrade_requirements.satisfies?(character)
      end

      unless @requirements_satisfied
        errors.add(:character, :requirements_no_satisfied)
      end

      @requirements_satisfied
    end

    def purchase_requirements_satisfied?
      if @requirements_satisfied.nil?
        @requirements_satisfied = purchase_requirements.satisfies?(character)
      end

      unless @requirements_satisfied
        errors.add(:character, :requirements_no_satisfied)
      end

      @requirements_satisfied
    end

    def requirements_satisfied?
      if @requirements_satisfied.nil?
        @requirements_satisfied = applicable_requirements.satisfies?(character)
      end

      unless @requirements_satisfied
        errors.add(:character, :requirements_no_satisfied)
      end
    end

    def assign_collected_at
      return true if collected_at

      # if it is first property, set short collect time
      if character.properties.count == 1 && Setting.i(:property_first_collect_time) != 0
        update_attribute(:collected_at, (collect_period.hours - Setting.i(:property_first_collect_time).seconds).ago)
      else
        update_attribute(:collected_at, created_at)
      end
    end
end
