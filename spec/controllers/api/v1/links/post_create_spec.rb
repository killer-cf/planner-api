require 'rails_helper'

describe Api::V1::LinksController do
  describe 'POST #create' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create :user }

    context 'valid params' do
      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create :trip
        create :participant, trip:, user: user

        link_valid_params = attributes_for(:link).merge(id: trip.id)

        expect do
          post :create, params: link_valid_params, format: :json
        end.to change(Link, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        link = Link.last
        expect(json_response['link_id']).to eq(link.id)
        expect(link_valid_params[:title]).to eq(link.title)
        expect(link_valid_params[:url]).to eq(link.url)
      end
    end

    context 'invalid params' do
      it 'returns a 422' do
        request.headers.merge!(authorization)
        trip = create :trip
        create :participant, trip:, user: user

        post :create, params: { title: nil, url: nil, id: trip.id }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        expect(json_response['errors']).to eq(['Title não pode ficar em branco', 'Url não pode ficar em branco',
                                               'Title é muito curto (mínimo: 4 caracteres)'])
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        trip = create :trip
        create :participant, trip:, user: user
        link_valid_params = attributes_for(:link).merge(id: trip.id)

        post :create, params: link_valid_params, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not a trip participant' do
        request.headers.merge!(authorization)
        trip = create :trip
        create :participant, user: user
        link_valid_params = attributes_for(:link).merge(id: trip.id)

        post :create, params: link_valid_params, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
