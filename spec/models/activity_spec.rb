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
end
