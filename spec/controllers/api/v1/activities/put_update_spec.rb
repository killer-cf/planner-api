require 'rails_helper'

describe Api::V1::ActivitiesController do
  describe 'PUT #update' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create(:user) }

    context 'authorized' do
      let(:new_attributes) do
        { title: 'Joao silva', occurs_at: 2.days.from_now }
      end

      it 'updates the requested trip' do
        request.headers.merge!(authorization)
        activity = create(:activity)
        create :participant, user:, trip: activity.trip

        put :update, params: { id: activity.to_param }.merge(new_attributes), format: :json

        activity.reload
        expect(response).to have_http_status(:no_content)
        expect(activity.title).to eq('Joao silva')
        expect(new_attributes[:occurs_at].to_date).to eq(activity.occurs_at.to_date)
      end
    end

    context 'unauthorized' do
      let(:new_attributes) do
        { title: 'Joao silva', occurs_at: 2.days.from_now }
      end

      it 'returns a 401' do
        activity = create(:activity)

        put :update, params: { id: activity.to_param }.merge(new_attributes), format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        activity = create(:activity)

        put :update, params: { id: activity.to_param }.merge(new_attributes), format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
