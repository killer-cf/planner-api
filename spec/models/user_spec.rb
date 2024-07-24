require 'rails_helper'

RSpec.describe User, type: :model do
  subject { create(:user) }

  describe 'associations' do
    it { is_expected.to have_many(:participants).dependent(:nullify) }
    it { is_expected.to have_many(:trips).through(:participants) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('email@addresse.foo').for(:email) }
    it { is_expected.not_to allow_value('email@address').for(:email) }
  end

  describe '#add_participants_by_emails' do
    let(:user) { create(:user) }
    let!(:participant1) { create(:participant, email: 'participant1@example.com') }
    let!(:participant2) { create(:participant, email: 'participant2@example.com') }
    let!(:participant3) { create(:participant, email: 'participant3@example.com') }

    it 'adds participants by email' do
      emails = ['participant1@example.com', 'participant2@example.com', nil, 'participant1@example.com', '']
      expect do
        user.add_participants_by_emails(emails)
      end.to change { user.participants.count }.by(2)

      expect(user.participants).to include(participant1, participant2)
      expect(user.participants).not_to include(participant3)
    end

    it 'ignores invalid or duplicate emails' do
      emails = [nil, '', 'participant1@example.com', 'participant2@example.com', 'participant1@example.com']
      user.add_participants_by_emails(emails)

      expect(user.participants.count).to eq(2)
      expect(user.participants).to include(participant1, participant2)
    end

    it 'does not add the same participant more than once' do
      emails = ['participant1@example.com', 'participant1@example.com']
      user.add_participants_by_emails(emails)

      expect(user.participants.count).to eq(1)
      expect(user.participants).to include(participant1)
    end
  end
end
