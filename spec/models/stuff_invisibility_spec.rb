require 'spec_helper'

describe StuffInvisibility do
  it 'should valitate uniqueness' do
    item = Factory.create :item
    character_type = Factory.create :character_type
    Factory.create :stuff_invisibility, :stuff => item, :character_type => character_type
    si = Factory.build :stuff_invisibility, :stuff => item, :character_type => character_type
    si.should_not be_valid
  end
end
