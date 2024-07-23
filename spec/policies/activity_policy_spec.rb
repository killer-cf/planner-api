require 'rails_helper'

RSpec.describe ActivityPolicy, type: :policy do
  subject { described_class.new(user, activity) }

  let(:user) { create(:user) }
  let(:activity) { build :activity }

  context 'with owner' do
    before { create :participant, user: user, trip: activity.trip, is_owner: true }

    it { is_expected.to permit_actions(%i[create destroy]) }
  end

  context 'with participant' do
    before { create :participant, user: user, trip: activity.trip }

    it { is_expected.to permit_actions(%i[create destroy]) }
  end

  context 'with other trip participants' do
    before do
      trip = create :trip
      create :participant, trip: trip
    end

    it { is_expected.to forbid_all_actions }
  end

  context 'with visitor' do
    it { is_expected.to forbid_all_actions }
  end
end
