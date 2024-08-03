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
      end

      it 'sends a mail to participants' do
        request.headers.merge!(authorization)
        expect do
          perform_enqueued_jobs do
            post :create, params: trip_params.merge(emails_to_invite: ['part1@gmail.com', 'part2@gmail.com'])
          end
        end.to change { ActionMailer::Base.deliveries.count }.by(2)

        deliveries = ActionMailer::Base.deliveries.last(2)
        expect(deliveries.map(&:to).flatten).to contain_exactly('part1@gmail.com', 'part2@gmail.com')
      end
    end
  end
end
