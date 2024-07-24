require 'rails_helper'

describe Api::V1::UsersController do
  describe 'GET #show' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

    context 'authorized' do
      let(:user) { create(:user) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create :participant, trip: trip, user: user

        get :show, params: { id: user.external_id }, format: :json

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['user']
        expect(json_response[:id]).to eq(user.id)
        expect(json_response[:email]).to eq(user.email)
        expect(json_response[:trip_ids]).to eq([trip.id])
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }

      it 'returns a 401' do
        user = create(:user)

        get :show, params: { id: user.external_id }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403' do
        request.headers.merge!(authorization)
        user = create(:user)

        get :show, params: { id: user.external_id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
