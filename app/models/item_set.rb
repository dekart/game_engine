class ItemSet < ActiveRecord::Base
  validates_presence_of :name

  validate :check_item_presence

  def item_ids=(value)
    @items = nil
    self[:item_ids] = value
  end

  def items
    unless @items
      if self[:item_ids].blank?
        @items = []
      else
        @items = JSON.parse(self[:item_ids]).collect do |item_id, frequency|
          if item = Item.find_by_id(item_id)
            [item, frequency]
          else
            nil
          end
        end

        @items.compact!
      end
    end

    @items
  end

  def items=(value)
    if value.is_a?(Hash)
      self.item_ids = value.values.collect{|params|
        params = params.symbolize_keys

        [params[:item_id].to_i, params[:frequency].to_i]
      }.to_json
    elsif value.is_a?(Array)
      self.item_ids = value.collect{|item_or_id, frequency|
        [
          item_or_id.is_a?(Item) ? item_or_id.id : item_or_id.to_i,
          frequency.to_i
        ]
      }.to_json
    elsif value.nil?
      self.item_ids = nil
    else
      raise ArgumentError
    end

    value
  end

  protected

  def check_item_presence
    errors.add(:items, :not_enough_items) if items.empty?
  end
end
