require 'rails_helper'

RSpec.describe ParticipantPolicy, type: :policy do
  subject { described_class.new(user, participant) }

  context 'with owner' do
    let(:user) { create(:user) }
    let(:participant) { build :participant }

    before { create :participant, user: user, trip: participant.trip, is_owner: true }

    it { is_expected.to permit_actions(%i[update destroy]) }
  end

  context 'with the user participant' do
    let(:user) { create(:user) }
    let(:participant) { build :participant, user: user }

    it { is_expected.to permit_actions(%i[update destroy]) }
  end

  context 'with participant' do
    let(:user) { create(:user) }
    let(:participant) { build :participant }

    before { create :participant, user: user, trip: participant.trip }

    it { is_expected.to forbid_actions(%i[update destroy]) }
  end

  context 'with other trip participants' do
    let(:user) { create(:user) }
    let(:participant) { build :participant }

    before do
      trip = create :trip
      create :participant, trip: trip
    end

    it { is_expected.to forbid_actions(%i[update destroy]) }
  end

  context 'with visitor' do
    let(:user) { create(:user) }
    let(:participant) { build :participant }

    it { is_expected.to forbid_actions(%i[update destroy]) }
  end
end
