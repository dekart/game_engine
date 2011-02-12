require 'spec_helper'

describe GlobalPayout do
  describe 'when creating' do
    should_validate_presence_of :name, :alias
  end
end