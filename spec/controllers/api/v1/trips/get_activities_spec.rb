require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'GET #activities' do
    context 'authorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        create_list(:activity, 5, trip: trip, occurs_at: 1.day.from_now)
        create(:participant, user:, trip:, email: user.email)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['activities']
        expect(json_response[0]['activities'].count).to eq(5)
      end

      it 'not return another trip activities' do
        request.headers.merge!(authorization)

        other_trip = create :trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now

        create_list(:activity, 5, trip: trip, occurs_at: 1.day.from_now)
        create_list(:activity, 2, trip: other_trip, occurs_at: 1.day.from_now)
        create(:participant, user:, trip:, email: user.email)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        json_response = response.parsed_body['activities']
        expect(json_response[0]['activities'].count).to eq(5)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now) }

      it 'returns a 401' do
        get :activities, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not participant' do
        request.headers.merge!(authorization)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
