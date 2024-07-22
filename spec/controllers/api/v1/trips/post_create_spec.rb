require 'rails_helper'
include ActiveJob::TestHelper

describe Api::V1::TripsController do
  let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }

  before do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    context 'with valid params' do
      let(:trip_params) { attributes_for(:trip).merge(owner_name: 'John Doe', owner_email: 'costa@gmail.com') }

      it 'creates a new trip' do
        request.headers.merge!(authorization)
        expect do
          post :create, params: trip_params,
                        format: :json
        end.to change(Trip, :count).by(1)
      end

      it 'renders a JSON response with the new trip' do
        request.headers.merge!(authorization)
        post :create, params: trip_params,
                      format: :json

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body
        trip = Trip.last
        expect(json_response['trip_id']).to eq(trip.id)
        expect(trip_params[:starts_at].to_date).to eq(trip.starts_at.to_date)
        expect(trip_params[:ends_at].to_date).to eq(trip.ends_at.to_date)
        expect(trip.is_confirmed).to be(false)
      end

      it 'sends a create trip email' do
        request.headers.merge!(authorization)
        expect do
          post :create, params: trip_params
        end.to have_enqueued_mail(TripMailer, :create_trip).with(
          params: {
            owner_name: 'John Doe',
            owner_email: 'costa@gmail.com',
            trip: an_instance_of(Trip)
          },
          args: []
        )

        expect(enqueued_jobs.size).to eq(1)
      end
    end
  end
end
