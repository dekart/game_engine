describe RewardPreview do
  describe '#as_json' do
    let :reward do
      RewardPreview.new(FactoryGirl.create(:character))
    end

    let :item do
      GameData::Item.define :some_item do |i|
      end
    end

    it 'should always return hash' do
      reward.as_json.must_be_kind_of Hash
    end

    it 'should properly return range values' do
      reward.take_basic_money 1..5

      reward.as_json['basic_money'].must_equal ['range', -5, -1]
    end

    it 'should properly return numeric values' do
      reward.give_vip_money 5

      reward.as_json['vip_money'].must_equal 5
    end

    it 'should return item values as array of items and amounts' do
      reward.give_item item, 2

      reward.as_json['items'].must_be_kind_of Array
      reward.as_json['items'][0].must_equal [item.as_json, 2]
    end
  end
end