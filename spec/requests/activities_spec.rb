require 'swagger_helper'

RSpec.describe 'api/v1/activities', type: :request do
  let(:user) { create(:user) }
  let(:trip) { create(:trip, starts_at: '2023-11-01', ends_at: '2023-12-30') }

  path '/api/v1/trips/{id}/activities' do
    parameter name: :id, in: :path, type: :string

    post 'Creates an activity' do
      tags 'Activities'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
      parameter name: :activity, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Visit Eiffel Tower' },
          occurs_at: { type: :string, format: 'date-time', example: '2023-12-01T10:00:00Z' }
        },
        required: %w[title occurs_at trip_id]
      }

      response '201', 'activity created' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:activity) { { title: 'Visit Eiffel Tower', occurs_at: '2023-12-01T10:00:00Z' } }

        schema type: :object,
               properties: {
                 activity_id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['activity_id']).not_to be_nil
        end
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { trip.id }
        let(:activity) { { title: 'Visit Eiffel Tower', occurs_at: '2023-12-01T10:00:00Z' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Forbidden' }
               },
               required: ['error']

        run_test!
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:activity) { { title: 'Visit Eiffel Tower' } }
        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Occurs at can't be blank" } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { trip.id }
        let(:authorization) { nil }
        let(:activity) { { title: 'Visit Eiffel Tower', occurs_at: '2023-12-01T10:00:00Z', trip_id: trip.id } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/activities/{id}' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    put 'Updates an activity' do
      tags 'Activities'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :activity_params, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Visit Louvre Museum' },
          occurs_at: { type: :string, format: 'date-time', example: '2023-12-02T10:00:00Z' }
        },
        required: %w[title occurs_at]
      }

      response '204', 'activity updated' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:activity) { create(:activity, trip: trip, occurs_at: '2023-12-02T10:00:00Z') }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:id) { activity.id }
        let(:activity_params) { { title: 'Visit Louvre Museum', occurs_at: '2023-12-02T10:00:00Z' } }

        run_test!
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:activity) { create(:activity, trip: trip, occurs_at: '2023-12-02T10:00:00Z') }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:id) { activity.id }
        let(:activity_params) { { title: 'ko' } }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Title can't be blank" } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:id) { 'invalid' }
        let(:activity_params) { { title: 'Visit Louvre Museum', occurs_at: '2023-12-02T10:00:00Z' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:activity) { create(:activity, trip: trip, occurs_at: '2023-12-02T10:00:00Z') }
        let(:id) { activity.id }
        let(:activity_params) { { title: 'Visit Louvre Museum', occurs_at: '2023-12-02T10:00:00Z' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Forbidden' }
               },
               required: ['error']

        run_test!
      end

      response '404', 'activity not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:id) { 'invalid' }
        let(:activity_params) { { title: 'Visit Louvre Museum', occurs_at: '2023-12-02T10:00:00Z' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Activity with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end

    delete 'Deletes an activity' do
      tags 'Activities'
      produces 'application/json'

      response '204', 'activity deleted' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:activity) { create(:activity, trip: trip, occurs_at: '2023-12-02T10:00:00Z') }
        let(:id) { activity.id }

        run_test!
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:activity) { create(:activity, trip: trip, occurs_at: '2023-12-02T10:00:00Z') }
        let(:id) { activity.id }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Forbidden' }
               },
               required: ['error']

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end

      response '404', 'activity not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Activity with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end
end
