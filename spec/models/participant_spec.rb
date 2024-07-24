require 'rails_helper'

RSpec.describe Participant, type: :model do
  describe '#valid' do
    subject { build :participant }

    it { is_expected.to validate_presence_of(:email) }

    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('user@example').for(:email) }
    it { is_expected.not_to allow_value('userexample.com').for(:email) }

    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:trip_id) }
  end

  describe 'callbacks' do
    let!(:user) { create(:user, email: 'test@example.com') }

    context 'before create' do
      it 'calls set_user' do
        participant = build(:participant, email: 'test@example.com')
        expect(participant).to receive(:set_user)
        participant.save
      end

      it 'sets the user based on email if user is not present' do
        participant = build(:participant, email: 'test@example.com', user: nil)
        participant.save
        expect(participant.user).to eq(user)
      end

      it 'does not overwrite an existing user' do
        other_user = create(:user, email: 'other@example.com')
        participant = build(:participant, email: 'test@example.com', user: other_user)
        participant.save
        expect(participant.user).to eq(other_user)
      end
    end
  end
end
