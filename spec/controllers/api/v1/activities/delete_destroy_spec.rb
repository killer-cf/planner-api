require 'rails_helper'

describe Api::V1::ActivitiesController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'DELETE #destroy' do
    let(:user) { create :user }

    context 'authorized' do
      it 'deletes the activity' do
        request.headers.merge!(authorization)
        activity = create :activity
        create :participant, trip: activity.trip, user: user

        expect do
          delete :destroy, params: { id: activity.id }, format: :json
        end.to change(Activity, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        activity = create(:activity)

        delete :destroy, params: { id: activity.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        activity = create(:activity)

        delete :destroy, params: { id: activity.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
