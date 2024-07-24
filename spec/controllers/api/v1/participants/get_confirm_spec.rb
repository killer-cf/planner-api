require 'rails_helper'
include ActiveJob::TestHelper

describe Api::V1::ParticipantsController do
  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe 'GET #confirm' do
    let(:user) { create(:user) }

    it 'redirect to frontend' do
      trip = create(:trip)
      participant = create(:participant, trip:, user:, is_confirmed: false)

      get :confirm, params: { id: participant.id }, format: :json

      participant.reload
      expect(response).to have_http_status(:found)
      expect(participant.is_confirmed).to be(true)
    end
  end
end
