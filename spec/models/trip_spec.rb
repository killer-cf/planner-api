require 'rails_helper'

RSpec.describe Trip, type: :model do
  describe '#valid?' do
    it { is_expected.to validate_presence_of(:destination) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }

    context 'when starts_at is not a valid datetime' do
      it 'is not valid' do
        trip = Trip.new(starts_at: 'invalid datetime', ends_at: DateTime.now + 1.day)
        trip.valid?
        expect(trip.errors[:starts_at]).to include('must be a valid date')
      end
    end

    context 'when ends_at is not a valid datetime' do
      it 'is not valid' do
        trip = Trip.new(starts_at: DateTime.now, ends_at: 'invalid datetime')
        trip.valid?
        expect(trip.errors[:ends_at]).to include('must be a valid date')
      end
    end

    context 'when starts_at and ends_at are valid datetimes' do
      it 'is valid' do
        trip = Trip.new(starts_at: DateTime.now, ends_at: DateTime.now + 1.day, destination: 'Test Destination')
        expect(trip).to be_valid
      end
    end

    context 'when ends_at is before starts_at' do
      it 'is not valid' do
        trip = Trip.new(starts_at: DateTime.now, ends_at: DateTime.now - 1.day, destination: 'Test Destination')
        trip.valid?
        expect(trip.errors[:ends_at]).to include('must be after the start date')
      end
    end

    context 'when ends_at is equal to starts_at' do
      it 'is not valid' do
        now = DateTime.now
        trip = Trip.new(starts_at: now, ends_at: now, destination: 'Test Destination')
        trip.valid?
        expect(trip.errors[:ends_at]).to include('must be after the start date')
      end
    end
  end

  describe 'callbacks' do
    let(:trip) { create(:trip, starts_at: Time.zone.today, ends_at: Time.zone.today + 6.days) }

    it 'deletes activities outside the new date range after update' do
      activity1 = create(:activity, trip:, occurs_at: Time.zone.today)
      activity2 = create(:activity, trip:, occurs_at: Time.zone.today + 1.day)
      activity3 = create(:activity, trip:, occurs_at: Time.zone.today + 3.days)
      activity4 = create(:activity, trip:, occurs_at: Time.zone.today + 4.days)
      activity5 = create(:activity, trip:, occurs_at: Time.zone.today + 5.days)

      trip.update(starts_at: Time.zone.today + 1.day, ends_at: Time.zone.today + 4.days)
      expect(trip.activities).to include(activity2)
      expect(trip.activities).to include(activity3)
      expect(trip.activities).to include(activity4)
      expect(trip.activities).not_to include(activity1)
      expect(trip.activities).not_to include(activity5)
    end
  end
end
