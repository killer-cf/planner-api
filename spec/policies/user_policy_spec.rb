require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, user_create) }

  context 'with user' do
    let(:user) { create(:user) }
    let(:user_create) { user }

    it { is_expected.to permit_actions(%i[show]) }
  end

  context 'with other users' do
    let(:user) { create(:user) }
    let(:user_create) { build :user }

    it { is_expected.to forbid_actions(%i[show]) }
  end
end
