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
end
