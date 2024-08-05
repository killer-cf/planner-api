require 'rails_helper'

describe Api::V1::TripsController do
  describe 'GET #current_participant' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

    context 'authorized' do
      let(:user) { create(:user) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create :trip
        participant = create :participant, trip: trip, user: user

        get :current_participant, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['participant']
        expect(json_response[:id]).to eq(participant.id)
        expect(json_response[:email]).to eq(participant.email)
        expect(json_response[:is_confirmed]).to eq(participant.is_confirmed)
        expect(json_response[:is_owner]).to eq(participant.is_owner)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }

      it 'returns a 401' do
        trip = create :trip
        user = create :user
        create :participant, trip: trip, user: user

        get :current_participant, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
