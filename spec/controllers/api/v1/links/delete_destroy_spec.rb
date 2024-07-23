require 'rails_helper'

describe Api::V1::LinksController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'DELETE #destroy' do
    let(:user) { create :user }

    context 'authorized' do
      it 'deletes the link' do
        request.headers.merge!(authorization)
        trip = create :trip
        link = create :link, trip: trip
        create :participant, trip:, user: user

        expect do
          delete :destroy, params: { id: link.id }, format: :json
        end.to change(Link, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        link = create(:link)

        delete :destroy, params: { id: link.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        link = create(:link)

        delete :destroy, params: { id: link.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
