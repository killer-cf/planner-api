require 'rails_helper'

describe Api::V1::ParticipantsController do
  describe 'DELETE #destroy' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create :user }

    context 'authorized' do
      it 'deletes the participant' do
        request.headers.merge!(authorization)
        trip = create :trip
        participant = create :participant, trip: trip
        create :participant, trip:, user: user, is_owner: true

        expect do
          delete :destroy, params: { id: participant.id }, format: :json
        end.to change(Participant, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        participant = create(:participant)

        delete :destroy, params: { id: participant.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create :trip
        participant = create(:participant, trip: trip)
        create :participant, trip:, user: user

        delete :destroy, params: { id: participant.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
