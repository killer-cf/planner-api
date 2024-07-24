require 'rails_helper'

describe Api::V1::ParticipantsController do
  describe 'PUT #update' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create(:user) }

    context 'authorized' do
      let(:new_attributes) do
        { name: 'Joao silva' }
      end

      it 'updates the requested trip' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        participant = create(:participant, user:, trip:)

        put :update, params: { id: participant.to_param }.merge(new_attributes), format: :json

        participant.reload
        expect(response).to have_http_status(:no_content)
        expect(participant.name).to eq('Joao silva')
      end
    end

    context 'unauthorized' do
      let(:new_attributes) do
        { name: 'Joao silva' }
      end

      it 'returns a 401' do
        trip = create(:trip)
        participant = create(:participant, user:, trip:)

        put :update, params: { id: participant.to_param }.merge(new_attributes), format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        participant = create(:participant, trip:)

        put :update, params: { id: participant.to_param }.merge(new_attributes), format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
