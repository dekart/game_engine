shared_examples_for "generic fight result calculator" do
  it 'should assign attacker' do
    @calculator.attacker.should == @attacker
  end
  
  it 'should assign victim' do
    @calculator.victim.should == @victim
  end

  it 'should return true or false' do
    [true, false].should include(@calculator.calculate)
  end
end