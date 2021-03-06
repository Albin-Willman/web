#encoding: UTF-8
require 'rails_helper'

RSpec.describe Rent, type: :model do
  subject(:rent) { FactoryGirl.build(:rent) }

  describe :Associations do
    it { should belong_to(:profile) }
    it { should belong_to(:council) }
  end

  describe :Validations do
    # Disclaimer
    it { should allow_value(true).for(:disclaimer) }
    it { should_not allow_value(false).for(:disclaimer) }

    describe :RequiredAttributes do
      it { should validate_presence_of(:d_from) }
      it { should validate_presence_of(:d_til) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:lastname) }
      it { should validate_presence_of(:phone) }
      it { should validate_presence_of(:email) }
    end

    describe :Purpose do
      context 'validate purpose when there is not profile' do
        before { allow(subject).to receive(:no_profile?).and_return(true) }
        it { should validate_presence_of(:purpose) }
      end
      context 'do not validate purpose when there is a profile' do
        before { allow(subject).to receive(:no_profile?).and_return(false) }
        it { should_not validate_presence_of(:purpose) }
      end
    end

    # Some tests for the duration method
    # /d.wessman
    describe :Duration do
      context :when_no_council do
        it 'add error if duration is over 48' do
          rent = FactoryGirl.build(:rent, :over_48)
          rent.valid?
          expect(rent.errors.get(:d_from)).to include(", får inte vara längre än 48 h")
        end
        it 'do not add error if duration is under 48' do
          rent = FactoryGirl.build(:rent, :under_48)
          rent.valid?
          expect(rent.errors.get(:d_from)).to be_nil or not_include(", får inte vara längre än 48 h")
        end
        it 'valid when duration is under 48' do
          rent = FactoryGirl.build(:good_rent, :under_48)
          expect(rent).to be_valid
        end
      end
      context :when_council do
        it 'do not add error if duration is over 48' do
          rent = FactoryGirl.build(:rent, :over_48, :with_council)
          rent.valid?
          expect(rent.errors.get(:d_from)).to be_nil or not_include(", får inte vara längre än 48 h")
        end
        it 'do not add error if duration is under 48' do
          rent = FactoryGirl.build(:rent, :under_48, :with_council)
          rent.valid?
          expect(rent.errors.get(:d_from)).to be_nil or not_include(", får inte vara längre än 48 h")
        end
        it 'valid for any duration' do
          rent = FactoryGirl.build(:good_rent, :over_48, :with_council)
          expect(rent).to be_valid
        end
      end
    end

    # Test to make sure rent is in future
    # /d.wessman
    describe :Dates_in_future do
      context :when_future do
        it 'add error if d_from > d_til' do
          rent = FactoryGirl.build(:rent)
          rent.d_from = rent.d_til + 1.hour
          rent.valid?
          expect(rent.errors.get(:d_til)).to include("måste vara efter startdatumet.")
        end
        it 'do not add error if d_from < d_til ' do
          rent = FactoryGirl.build(:rent)
          rent.valid?
          expect(rent.errors.get(:d_til)).to be_nil or not_include("måste vara efter startdatumet.")
        end
        it 'no other validation failing' do
          rent = FactoryGirl.build(:good_rent)
          expect(rent).to be_valid
        end
      end
      context :when_past do
        it 'add error if d_from > d_til' do
          rent = FactoryGirl.build(:rent)
          rent.d_til = Time.zone.now - 10.hours
          rent.d_from = rent.d_til + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_til)).to include("måste vara efter startdatumet.")
        end
        it 'add error if d_from > d_til' do
          rent = FactoryGirl.build(:rent)
          rent.d_til = Time.zone.now - 10.hours
          rent.d_from = rent.d_til + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to include("måste vara i framtiden.")
        end
        it 'add error if d_from < d_til' do
          rent = FactoryGirl.build(:rent)
          rent.d_from = Time.zone.now - 10.hours
          rent.d_til = rent.d_from + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to include("måste vara i framtiden.")
        end
      end
    end



    # Validate if overlap
    # /d.wessman
    describe :Overlap do
      context :when_no_councils do
        it 'invalid when d_til is within saved rent' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_from - 5.hours
          rent.d_til = overlap.d_til - 5.hours
          expect(rent).to_not be_valid
        end
        it 'invalid when d_from and d_til is within saved rent' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_from + 5.hours
          rent.d_til = overlap.d_til - 5.hours
          expect(rent).to_not be_valid
        end
        it 'do add error if d_from is within saved' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_from + 5.hours
          rent.d_til = overlap.d_til - 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to include("överlappar med annan bokning")
        end
        it 'invalid when d_from is within saved rent' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_til - 5.hours
          rent.d_til = overlap.d_til + 5.hours
          expect(rent).to_not be_valid
        end
        it 'do add error if d_from is within saved' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_til - 5.hours
          rent.d_til = overlap.d_til + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to include("överlappar med annan bokning")
        end

        it 'valid when d_from and d_til is outside saved rent' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_til + 5.hours
          rent.d_til = rent.d_from + 5.hours
          expect(rent).to be_valid
        end
        it 'do not add error if d_til and d_from is outside saved' do
          overlap = FactoryGirl.create(:good_rent)
          rent = FactoryGirl.build(:good_rent)
          rent.d_from = overlap.d_til + 5.hours
          rent.d_til = rent.d_from + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to be_nil or not_include("överlappar med annan bokning")
        end
      end
      context :when_first_council_second_not do
         it 'invalid when d_til is within good rent' do
           overlap = FactoryGirl.create(:good_rent,:with_council)
           rent = FactoryGirl.build(:good_rent)
           rent.d_from = overlap.d_from - 5.hours
           rent.d_til = overlap.d_til - 5.hours
           expect(rent).to_not be_valid
         end
         it 'add error if d_til within saved' do
           overlap = FactoryGirl.create(:good_rent,:with_council)
           rent = FactoryGirl.build(:good_rent)
           rent.d_from = overlap.d_from - 5.hours
           rent.d_til = overlap.d_til - 5.hours
           rent.valid?
           expect(rent.errors.get(:d_from)).to include("överlappar med annan bokning")
         end
         it 'invalid when d_from and d_til is within saved' do
           overlap = FactoryGirl.create(:good_rent,:with_council)
           rent = FactoryGirl.build(:good_rent)
           rent.d_from = overlap.d_from + 5.hours
           rent.d_til = overlap.d_til - 5.hours
           expect(rent).to_not be_valid
         end
         it 'invalid when d_from is within saved rent' do
           overlap = FactoryGirl.create(:good_rent,:with_council)
           rent = FactoryGirl.build(:good_rent)
           rent.d_from = overlap.d_til - 5.hours
           rent.d_til = overlap.d_til + 5.hours
           expect(rent).to_not be_valid
         end
         it 'valid when d_from and d_til is outside saved rent' do
           overlap = FactoryGirl.create(:good_rent,:with_council)
           rent = FactoryGirl.build(:good_rent)
           rent.d_from = overlap.d_til + 5.hours
           rent.d_til = rent.d_from + 5.hours
           expect(rent).to be_valid
         end
      end

      context :when_second_council_first_not do
         it 'valid when d_til is within good rent' do
           overlap = FactoryGirl.create(:good_rent)
           rent = FactoryGirl.build(:good_rent,:with_council)
           rent.d_from = overlap.d_from - 5.hours
           rent.d_til = overlap.d_til - 5.hours
           expect(rent).to be_valid
         end
         it 'valid when d_from and d_til is within good rent' do
           overlap = FactoryGirl.create(:good_rent)
           rent = FactoryGirl.build(:good_rent,:with_council)
           rent.d_from = overlap.d_from + 5.hours
           rent.d_til = overlap.d_til - 5.hours
           expect(rent).to be_valid
         end
         it 'valid when d_from is within good rent' do
           overlap = FactoryGirl.create(:good_rent)
           rent = FactoryGirl.build(:good_rent,:with_council)
           rent.d_from = overlap.d_til - 5.hours
           rent.d_til = overlap.d_til + 5.hours
           expect(rent).to be_valid
         end
         it 'valid when d_from and d_til is outside good rent' do
           overlap = FactoryGirl.create(:good_rent)
           rent = FactoryGirl.build(:good_rent,:with_council)
           rent.d_from = overlap.d_til + 5.hours
           rent.d_til = rent.d_from + 5.hours
           expect(rent).to be_valid
         end
      end
      context :when_two_councils do
        it 'invalid when d_til is within good rent' do
          overlap = FactoryGirl.create(:good_rent,:with_council)
          rent = FactoryGirl.build(:good_rent,:with_council)
          rent.d_from = overlap.d_from - 5.hours
          rent.d_til = overlap.d_til - 5.hours
          expect(rent).to_not be_valid
        end
        it 'do add error if d_til within saved' do
          overlap = FactoryGirl.create(:good_rent,:with_council)
          rent = FactoryGirl.build(:good_rent,:with_council)
          rent.d_from = overlap.d_from - 5.hours
          rent.d_til = overlap.d_til + 5.hours
          rent.valid?
          expect(rent.errors.get(:d_from)).to include("överlappar med annan utskottsbokning")
        end
        it 'invalid when d_from and d_til is within good rent' do
          overlap = FactoryGirl.create(:good_rent,:with_council)
          rent = FactoryGirl.build(:good_rent,:with_council)
          rent.d_from = overlap.d_from + 5.hours
          rent.d_til = overlap.d_til - 5.hours
          expect(rent).to_not be_valid
        end
        it 'invalid when d_from is within good rent' do
          overlap = FactoryGirl.create(:good_rent,:with_council)
          rent = FactoryGirl.build(:good_rent,:with_council)
          rent.d_from = overlap.d_til - 5.hours
          rent.d_til = overlap.d_til + 5.hours
          expect(rent).to_not be_valid
        end
        it 'valid when d_from and d_til is outside good rent' do
          overlap = FactoryGirl.create(:good_rent,:with_council)
          rent = FactoryGirl.build(:good_rent,:with_council)
          rent.d_from = overlap.d_til + 5.hours
          rent.d_til = rent.d_from + 5.hours
          expect(rent).to be_valid
        end
      end
    end
  end
end
