require 'spec_helper'

describe CreditPackage do
  it 'should have an image' do
    @package = CreditPackage.new
    
    @package.should respond_to(:image?)
    @package.image.should be_kind_of(Paperclip::Attachment)
  end

  it 'should order by amount of vip money by default' do
    @package1 = Factory(:credit_package, :vip_money => 10)
    @package2 = Factory(:credit_package, :vip_money => 5)
    
    CreditPackage.all.should == [@package2, @package1]
  end
  
  
  shared_examples_for 'save or update' do
    %w{vip_money price}.each do |attr|
      it "should validate presence of #{attr}" do
        @package.should validate_presence_of(attr)
      end
    
      it "should validate numericality of #{attr}" do
        @package.should validate_numericality_of(attr)
      end
    
      it "should not allow negative values for #{attr}" do
        @package.should allow_value(1).for(attr)
        @package.should_not allow_value(0).for(attr)
        @package.should_not allow_value(-1).for(attr)
      end
    end
    
    it 'should reset default flag for other packages if marked as default' do
      @other_package = Factory(:credit_package)
      @other_package.should be_default
      
      @package.default = true
      @package.save
      
      @other_package.reload.should_not be_default
    end
    
    it 'should not change default flag for other packages if not marked as default' do
      @other_package = Factory(:credit_package)
      @other_package.should be_default
      
      @package.default = false
      @package.save
      
      @other_package.reload.should be_default
    end
  end


  describe '#create' do
    before do
      @package = Factory.build(:credit_package)
    end
    
    it_should_behave_like 'save or update'
  end
  
  
  describe '#save' do
    before do
      @package = Factory(:credit_package)
    end
    
    it_should_behave_like 'save or update'
  end
  
  
  describe '#publish' do
    before do
      @package = Factory(:credit_package)
    end

    it 'should keep its default flag if marked as default' do
      @package.publish
      
      @package.reload.should be_default
    end
  end
end