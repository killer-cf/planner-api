require 'rails_helper'

describe Api::V1::TripsController do
  describe 'GET #index' do
    let!(:trips) { create_list(:trip, 5) }

    it 'returns a success response' do
      get :index, format: :json

      expect(response).to be_successful
      expect(response.content_type).to eq('application/json; charset=utf-8')
      json_response = response.parsed_body['trips']
      expect(json_response.count).to eq(5)
    end

    it 'paginates results and provide metadata' do
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
  end

  describe 'GET #show' do
    context '' do
      it 'returns a success response' do
        trip = create(:trip)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['trip']
        expect(json_response['destination']).to eq(trip.destination)
        expect(Date.parse(json_response['starts_at'])).to eq(trip.starts_at)
        expect(Date.parse(json_response['ends_at'])).to eq(trip.ends_at)
        expect(json_response['is_confirmed']).to eq(trip.is_confirmed)
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new trip' do
        expect do
          post :create, params: { trip: attributes_for(:trip) },
                        format: :json
        end.to change(Trip, :count).by(1)
      end

      it 'renders a JSON response with the new trip' do
        post :create, params: { trip: attributes_for(:trip)},
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['trip']
        trip = Trip.last
        expect(json_response['destination']).to eq(trip.destination)
        expect(Date.parse(json_response['starts_at'])).to eq(trip.starts_at.to_date)
        expect(Date.parse(json_response['ends_at'])).to eq(trip.ends_at.to_date)
        expect(json_response['is_confirmed']).to be(false)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { destination: 'Recife, Brazil', ends_at: 1.week.from_now, starts_at: 1.day.from_now }
      end

      it 'updates the requested trip' do
        trip = create(:trip)
        put :update, params: { id: trip.to_param, trip: new_attributes }, format: :json
        trip.reload
        expect(trip.destination).to eq('Recife, Brazil')
        expect(trip.starts_at.to_date).to eq(1.day.from_now.to_date)
        expect(trip.ends_at.to_date).to eq(1.week.from_now.to_date)
      end
    end
  end

  describe 'DELETE #destroy' do
    context '' do
      it 'deletes the trip' do
        trip = create(:trip)

        expect do
          delete :destroy, params: { id: trip.id }, format: :json
        end.to change(Trip, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
