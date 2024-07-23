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

  describe 'POST #invites' do
    let(:user) { create(:user) }

    context 'with valid params' do
      it 'sends a mail' do
        trip = create(:trip)
        create(:participant, trip: trip, email: user.email, is_owner: true)
        request.headers.merge!(authorization)

        expect do
          post :invites, params: { id: trip.id, name: 'John Doe', email: 'costa@gmail.com' },
                         format: :json
        end.to have_enqueued_mail(TripMailer, :confirm_trip).with(
          params: {
            email: 'costa@gmail.com',
            participant_id: an_instance_of(String),
            trip: an_instance_of(Trip)
          },
          args: []
        )
      end

      it 'returns a success response' do
        trip = create(:trip)
        create(:participant, trip: trip, email: user.email, is_owner: true)
        request.headers.merge!(authorization)

        post :invites, params: { id: trip.id, name: 'John Doe', email: 'costa@gmail.com' }, format: :json

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'with invalid params' do
      it 'returns a 422' do
        trip = create(:trip)
        create(:participant, trip: trip, email: user.email, is_owner: true)
        request.headers.merge!(authorization)

        post :invites, params: { id: trip.id, name: 'John Doe', email: '' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body['errors']
        expect(json_response).to eq(['Participants não é válido'])
      end
    end

    context 'unauthorized' do
      let(:trip) { create(:trip) }

      it 'returns a 401' do
        post :invites, params: { id: trip.id, name: 'John Doe', email: 'costa@gmail.com' }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        post :invites, params: { id: trip.id, name: 'John Doe', email: 'costa@gmail.com' }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
