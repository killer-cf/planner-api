require 'rails_helper'

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  describe 'GET #index' do
    let(:user) { create(:user) }
    let!(:trips) { create_list(:trip, 5) { |trip| create(:participant, user:, trip:) } }

    it 'returns a success response' do
      request.headers.merge!(authorization)

      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['trips']
      expect(json_response.count).to eq(5)
    end

    it 'paginates results and provide metadata' do
      request.headers.merge!(authorization)
      get :index, params: { page: 2, per_page: 2 }, format: :json

      json_response = response.parsed_body['trips']
      expect(json_response.count).to eq(2)

      meta = response.parsed_body['meta']
      expect(meta['current_page']).to eq(2)
      expect(meta['next_page']).to eq(3)
      expect(meta['prev_page']).to eq(1)
      expect(meta['total_pages']).to eq(3)
      expect(meta['total_count']).to eq(5)
    end

    it 'dont return other user trips' do
      other_trip = create(:trip)

      request.headers.merge!(authorization)
      get :index, format: :json

      json_response = response.parsed_body['trips']
      expect(json_response.count).to eq(5)
      expect(json_response.pluck('id')).not_to include(other_trip.id)
    end
  end
end
