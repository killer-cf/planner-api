require 'rails_helper'

RSpec.describe Activity, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:occurs_at) }
  it { is_expected.to validate_length_of(:title).is_at_least(4) }

  context 'when occurs_at is not a valid datetime' do
    it 'is not valid' do
      activity = Activity.new(occurs_at: 'invalid datetime')
      activity.valid?
      expect(activity.errors[:occurs_at]).to include('must be a valid date')
    end
  end

  describe 'validations' do
    let(:trip) { create(:trip, starts_at: Time.zone.today, ends_at: Time.zone.today + 5.days) }

    it 'is valid when occurs_at is within the trip range' do
      activity = build(:activity, trip: trip, occurs_at: Time.zone.today + 2.days)
      expect(activity).to be_valid
    end

    it 'is invalid when occurs_at is before the trip start date' do
      activity = build(:activity, trip: trip, occurs_at: Time.zone.today - 1.day)
      expect(activity).not_to be_valid
      expect(activity.errors[:occurs_at]).to include('must be within the trip start and end dates')
    end

    it 'is invalid when occurs_at is after the trip end date' do
      activity = build(:activity, trip: trip, occurs_at: Time.zone.today + 6.days)
      expect(activity).not_to be_valid
      expect(activity.errors[:occurs_at]).to include('must be within the trip start and end dates')
    end
  end
end
