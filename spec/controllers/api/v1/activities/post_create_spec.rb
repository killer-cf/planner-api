require 'rails_helper'

describe Api::V1::ActivitiesController do
  describe 'DELETE #destroy' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create :user }

    context 'valid params' do
      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create :trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now
        create :participant, trip:, user: user

        activity_valid_params = attributes_for(:activity).merge(id: trip.id)

        expect do
          post :create, params: activity_valid_params, format: :json
        end.to change(Activity, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        activity = Activity.last
        expect(json_response['activity_id']).to eq(activity.id)
        expect(activity_valid_params[:title]).to eq(activity.title)
        expect(activity_valid_params[:occurs_at].to_date).to eq(activity.occurs_at.to_date)
      end
    end

    context 'invalid params' do
      it 'returns a 422' do
        request.headers.merge!(authorization)
        trip = create :trip
        create :participant, trip:, user: user

        post :create, params: { title: nil, occurs_at: nil, id: trip.id }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['errors']).to eq(['Title não pode ficar em branco',
                                               'Occurs at não pode ficar em branco',
                                               'Title é muito curto (mínimo: 4 caracteres)',
                                               'Occurs at must be a valid date'])
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        trip = create :trip
        create :participant, trip:, user: user
        activity_valid_params = attributes_for(:activity).merge(id: trip.id)

        post :create, params: activity_valid_params, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not a trip participant' do
        request.headers.merge!(authorization)
        trip = create :trip
        create :participant, user: user
        activity_valid_params = attributes_for(:activity).merge(id: trip.id)

        post :create, params: activity_valid_params, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
