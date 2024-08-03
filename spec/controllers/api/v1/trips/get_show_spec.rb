require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'GET #show' do
    context 'authorized' do
      let(:user) { create(:user) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['trip']
        expect(json_response['destination']).to eq(trip.destination)
        expect(Date.parse(json_response['starts_at'])).to eq(trip.starts_at)
        expect(Date.parse(json_response['ends_at'])).to eq(trip.ends_at)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }

      it 'returns a 401' do
        trip = create(:trip)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403' do
        request.headers.merge!(authorization)
        trip = create(:trip)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
