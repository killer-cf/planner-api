require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    context 'authorized' do
      it 'deletes the trip' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: true)

        expect do
          delete :destroy, params: { id: trip.id }, format: :json
        end.to change(Trip, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        trip = create(:trip)

        delete :destroy, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: false)

        delete :destroy, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
