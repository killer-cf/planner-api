require 'rails_helper'
include ActiveJob::TestHelper

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

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

    it 'sends a mail to participants' do
      trip = create(:trip)
      create(:participant, trip: trip, email: user.email, is_owner: true)
      create(:participant, trip: trip, email: 'user1@gmail.com')
      create(:participant, trip: trip, email: 'user2@gmail.com')

      expect do
        perform_enqueued_jobs do
          get :confirm, params: { id: trip.id }, format: :json
        end
      end.to change { ActionMailer::Base.deliveries.count }.by(2)

      deliveries = ActionMailer::Base.deliveries.last(2)
      expect(deliveries.map(&:to).flatten).to contain_exactly('user1@gmail.com', 'user2@gmail.com')
    end

    it 'redirect to frontend' do
      trip = create(:trip)

      get :confirm, params: { id: trip.id }, format: :json

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to("http://localhost:3000/trips/#{trip.id}")
    end

    it 'update trip to confirmed' do
      trip = create(:trip, is_confirmed: false)

      get :confirm, params: { id: trip.id }, format: :json

      trip.reload
      expect(trip.is_confirmed).to be(true)
    end
  end
end
