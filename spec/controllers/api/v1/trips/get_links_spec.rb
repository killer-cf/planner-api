require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'GET #links' do
    context 'authorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        create_list(:link, 5, trip: trip)
        create(:participant, user:, trip:, email: user.email)

        get :links, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['links']
        expect(json_response.count).to eq(5)
      end

      it 'not return another trip links' do
        request.headers.merge!(authorization)
        create_list(:link, 5, trip: trip)
        create_list(:link, 2)
        create(:participant, user:, trip:, email: user.email)

        get :links, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        json_response = response.parsed_body['links']
        expect(json_response.count).to eq(5)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip) }

      it 'returns a 401' do
        get :links, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not participant' do
        request.headers.merge!(authorization)

        get :links, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
