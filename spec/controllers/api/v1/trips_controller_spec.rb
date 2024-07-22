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

  describe 'GET #index' do
    let(:user) { create(:user) }
    let!(:trips) { create_list(:trip, 5) }

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
  end

  describe 'GET #show' do
    context 'authorized' do
      let(:user) { create(:user) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email)

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

    context 'unauthorized' do
      let(:user) { create(:user) }

      it 'returns a 401' do
        trip = create(:trip)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403' do
        request.headers.merge!(authorization)
        trip = create(:trip)

        get :show, params: { id: trip.to_param }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
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

  describe 'PUT #update' do
    let(:user) { create(:user) }

    context 'authorized' do
      let(:new_attributes) do
        { destination: 'Recife, Brazil', ends_at: 1.week.from_now, starts_at: 1.day.from_now }
      end

      it 'updates the requested trip' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: true)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        trip.reload
        expect(trip.destination).to eq('Recife, Brazil')
        expect(trip.starts_at.to_date).to eq(1.day.from_now.to_date)
        expect(trip.ends_at.to_date).to eq(1.week.from_now.to_date)
      end
    end

    context 'unauthorized' do
      let(:new_attributes) do
        { destination: 'Recife, Brazil', ends_at: 1.week.from_now, starts_at: 1.day.from_now }
      end

      it 'returns a 401' do
        trip = create(:trip)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email)
        put :update, params: { id: trip.to_param }.merge(new_attributes), format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    context 'authorized' do
      it 'deletes the trip' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: true)

        expect do
          delete :destroy, params: { id: trip.id }, format: :json
        end.to change(Trip, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'unauthorized' do
      it 'returns a 401' do
        trip = create(:trip)

        delete :destroy, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not owner' do
        request.headers.merge!(authorization)
        trip = create(:trip)
        create(:participant, user:, trip:, email: user.email, is_owner: false)

        delete :destroy, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #activities' do
    context 'authorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        create_list(:activity, 5, trip: trip, occurs_at: 1.day.from_now)
        create(:participant, user:, trip:, email: user.email)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['activities']
        expect(json_response[0]['activities'].count).to eq(5)
      end

      it 'not return another trip activities' do
        request.headers.merge!(authorization)
        create_list(:activity, 5, trip: trip, occurs_at: 1.day.from_now)
        create_list(:activity, 2, occurs_at: 1.day.from_now)
        create(:participant, user:, trip:, email: user.email)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        json_response = response.parsed_body['activities']
        expect(json_response[0]['activities'].count).to eq(5)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now) }

      it 'returns a 401' do
        get :activities, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not participant' do
        request.headers.merge!(authorization)

        get :activities, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET #participants' do
    context 'authorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip) }

      it 'returns a success response' do
        request.headers.merge!(authorization)
        create_list(:participant, 5, trip: trip)
        create :participant, user:, trip:, email: 'userjk@gmail.com', is_owner: true

        get :participants, params: { id: trip.id }, format: :json

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_response = response.parsed_body['participants']
        expect(json_response.count).to eq(5)
      end
    end

    context 'unauthorized' do
      let(:user) { create(:user) }
      let(:trip) { create(:trip) }

      it 'returns a 401' do
        get :participants, params: { id: trip.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns a 403 if is not participant' do
        request.headers.merge!(authorization)

        get :participants, params: { id: trip.id }, format: :json

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
