require 'spec_helper'

describe MissionResult do
  describe 'when performing mission' do
    before do
      @character = Factory(:character)

      @mission = Factory(:mission)
      @mission_level = Factory(:mission_level, :mission => @mission)

      @payout_success = Payouts::DummyPayout.new(:apply_on => :success)
      @payout_failure = Payouts::DummyPayout.new(:apply_on => :failure)
      @payout_repeat_success = Payouts::DummyPayout.new(:apply_on => :repeat_success)
      @payout_repeat_failure = Payouts::DummyPayout.new(:apply_on => :repeat_failure)
      @payout_complete = Payouts::DummyPayout.new(:apply_on => :complete)

      @payouts = Payouts::Collection.new(
        @payout_success, @payout_repeat_success, @payout_complete, @payout_failure, @payout_repeat_failure
      )
    end

    def mission_result
      @mission_result ||= MissionResult.new(@character, @mission)
    end

    def progress_level!(level, progress)
      MissionLevelRank.create(
        :level      => level,
        :character  => @character,
        :progress   => progress
      )
      @character.missions.check_completion!(@mission)
    end

    it 'should not be saved if character doesn\'t have enough energy' do
      @character.ep = 0

      mission_result.save!

      mission_result.should_not be_saved
    end

    it 'should not be saved if mission is not repeatable and current level is already completed' do
      mission_result.level_rank.update_attributes(
        :progress => @mission_level.win_amount
      )
      @character.missions.check_completion!(@mission)

      mission_result.save!

      mission_result.should_not be_saved
    end

    it 'should not be saved if mission requirements are not satisfied' do
      @mission.requirements = Requirements::Collection.new(
        Requirements::Level.new(:value => 100)
      )

      mission_result.save!

      mission_result.should_not be_saved
    end

    describe 'when mission is valid' do
      it 'should succeed if we hit success chance' do
        Dice.should_receive(:chance).at_least(1).and_return(true)

        mission_result.save!

        mission_result.should be_success
      end

      it 'should not succeed if we don\'t hit success chance' do
        Dice.should_receive(:chance).at_least(1).and_return(false)

        mission_result.save!

        mission_result.should_not be_success
      end

      it 'should be done for free if we hit character\'s mission energy assignment chance' do
        @character.assignments.should_receive(:mission_energy_effect).and_return(20)

        Dice.should_receive(:chance).at_least(1).and_return(true)

        lambda{
          mission_result.save!
        }.should_not change(@character, :ep)

        mission_result.should be_free_fulfillment
      end

      describe 'when not done for free' do
        it 'should charge energy' do
          lambda{
            mission_result.save!
          }.should change(@character, :ep).from(10).to(5)
        end

        describe 'when character have boosts' do
          before do
            @energy_boost = Factory(:item, :boost => true)

            @character.inventories.give!(@energy_boost)
          end
                    
          describe 'when boost has energy bonus within required value' do
            before do
              @energy_boost.update_attributes(:energy => 4)
            end

            it 'should use energy boost' do
              mission_result.save!
              mission_result.boost.item.should == @energy_boost
            end
            
            it 'should reduce energy cost by boost bonus' do
              lambda{
                mission_result.save!
              }.should change(@character, :ep).from(10).to(9)
            end

            it 'should take boost from character' do
              mission_result.save!

              @character.inventories.should be_empty
            end
          end

          shared_examples_for 'boost that don\'t fit' do
            it 'should not use boost' do
              mission_result.save!

              mission_result.boost.should be_nil
            end

            it 'should charge energy in full' do
              lambda{
                mission_result.save!
              }.should change(@character, :ep).from(10).to(5)
            end

            it 'should not take boost from character' do
              mission_result.save!

              @character.inventories.should_not be_empty
            end
          end

          describe 'when boost does\'t have energy bonus' do
            before do
              @energy_boost.update_attributes(:attack => 1)
            end

            it_should_behave_like "boost that don\'t fit"
          end

          describe 'when boost is more powerfull than requires' do
            before do
              @energy_boost.update_attribute(:energy, 10)
            end

            it_should_behave_like "boost that don\'t fit"
          end
        end
      end

      describe 'when done successfully' do
        before do
          Dice.stub!(:chance => true)
        end
        
        it 'should give experience to user' do
          lambda{
            mission_result.save!
          }.should change(@character, :experience).from(0).to(5)

          mission_result.experience.should == 5
        end

        it 'should give money to user' do
          mission_result.level.should_receive(:money).and_return(100)

          lambda{
            mission_result.save!
          }.should change(@character, :basic_money).from(0).to(100)

          mission_result.money.should == 100
        end

        it 'should increase level progress' do
          mission_result.save!

          @character.mission_levels.rank_for(@mission).progress.should == 1
        end

        it 'should increase succeeded mission counter' do
          lambda{
            mission_result.save!
          }.should change(@character, :missions_succeeded).from(0).to(1)
        end

        describe 'if level is just completed' do
          before do
            progress_level!(@mission_level, 4)
          end

          it 'should increase completed mission counter' do
            lambda{
              mission_result.save!
            }.should change(@character, :missions_completed).from(0).to(1)
          end


          it 'should increase mastered mission counter if doing last level of the mission' do
            @second_level = Factory(:mission_level, :mission => @mission)
            @second_level.move_higher

            progress_level!(@second_level, 5)
            
            @character.missions.check_completion!(@mission)

            lambda{
              mission_result.save!
            }.should change(@character, :missions_mastered).from(0).to(1)
          end

          it 'should not increase mastered mission counter if doing non-last level' do
            @second_level = Factory(:mission_level, :mission => @mission)

            lambda{
              mission_result.save!
            }.should_not change(@character, :missions_mastered)
          end

          it 'should give upgrade point to character' do
            lambda{
              mission_result.save!
            }.should change(@character, :points).from(0).to(1)
          end

          it 'should apply :complete payouts of level' do
            mission_result.level.payouts = @payouts

            lambda{
              mission_result.save!
            }.should change(@payout_complete, :applied).from(nil).to(true)

            mission_result.payouts.size.should == 1
            mission_result.payouts.first.should == @payout_complete
          end

          it 'should check completion of mission' do
            @mission_rank = mock('Mission Rank')

            @character.missions.should_receive(:check_completion!).and_return(@mission_rank)

            mission_result.save!

            mission_result.mission_rank.should == @mission_rank
          end
          
          it 'should check completion of mission group' do
            @group_rank = mock('Group Rank')
            @group_payouts = mock('Group Payouts')

            @character.mission_groups.
              should_receive(:check_completion!).
              and_return([@group_rank, @group_payouts])

            mission_result.save!

            mission_result.group_rank.should == @group_rank
            mission_result.group_payouts.should == @group_payouts
          end
          
          it 'should add news about completed mission to character' do
            lambda{
              mission_result.save!
            }.should change(@character.news, :count).from(0).to(1)

            @character.news.first.should be_kind_of(News::MissionComplete)
            @character.news.first.mission.should == @mission
            @character.news.first.level_rank.should == mission_result.level_rank
          end
        end

        it 'should apply :success if mission is not completed yet' do
          mission_result.level.payouts = @payouts

          lambda{
            mission_result.save!
          }.should change(@payout_success, :applied).from(nil).to(true)

          mission_result.payouts.size.should == 1
          mission_result.payouts.first.should == @payout_success
        end

        it 'should apply :repeat_success if mission is already completed in past' do
          @mission.update_attributes(:repeatable => true)

          progress_level!(@mission_level, 5)

          mission_result.level.payouts = @payouts

          lambda{
            mission_result.save!
          }.should change(@payout_repeat_success, :applied).from(nil).to(true)

          mission_result.payouts.size.should == 1
          mission_result.payouts.first.should == @payout_repeat_success
        end
      end

      describe 'when failed' do
        before do
          Dice.stub!(:chance => false)
        end

        it 'should apply :failure payouts if level is not completed yet' do
          mission_result.level.payouts = @payouts

          lambda{
            mission_result.save!
          }.should change(@payout_failure, :applied).from(nil).to(true)

          mission_result.payouts.size.should == 1
          mission_result.payouts.first.should == @payout_failure
        end

        it 'should apply :repeat_failure payouts if level is already completed' do
          @mission.update_attributes(:repeatable => true)

          progress_level!(@mission_level, 5)

          mission_result.level.payouts = @payouts

          lambda{
            mission_result.save!
          }.should change(@payout_repeat_failure, :applied).from(nil).to(true)

          mission_result.payouts.size.should == 1
          mission_result.payouts.first.should == @payout_repeat_failure
        end
      end
    end

    describe 'when mission is repeatable' do
      before do
        @mission.update_attributes(:repeatable => true)
      end

      it 'should be saved if level is already completed' do
        mission_result.save!

        mission_result.should be_saved
      end
    end
  end
end