require 'rails_helper'

describe Api::V1::TripsController do
  describe 'GET #participants' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create(:user) }
    let(:trip) { create(:trip) }

    context 'authorized' do
      it 'returns a success response' do
        request.headers.merge!(authorization)
        create_list(:participant, 5, trip: trip)
        create(:participant, user: user, trip: trip, email: user.email, is_owner: true)

        get :participants, params: { id: trip.id }, format: :json

        puts response.parsed_body

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['participants']
        expect(json_response.count).to eq(5)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        get :participants, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not participant' do
        request.headers.merge!(authorization)

        get :participants, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
