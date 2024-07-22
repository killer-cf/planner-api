require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'PUT #update' do
    let(:user) { create(:user) }

    context 'authorized' do
      let(:new_attributes) do
        { destination: 'Recife, Brazil', ends_at: 1.week.from_now, starts_at: 1.day.from_now }
      end

      it 'updates the requested trip' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: true)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        trip.reload
        expect(trip.destination).to eq('Recife, Brazil')
        expect(trip.starts_at.to_date).to eq(1.day.from_now.to_date)
        expect(trip.ends_at.to_date).to eq(1.week.from_now.to_date)
      end
    end

    context 'unauthorized' do
      let(:new_attributes) do
        { destination: 'Recife, Brazil', ends_at: 1.week.from_now, starts_at: 1.day.from_now }
      end

      it 'returns a 401' do
        trip = create(:trip)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
