require 'swagger_helper'

RSpec.describe 'api/v1/links', type: :request do
  let(:user) { create(:user) }
  let(:trip) { create(:trip) }

  path '/api/v1/trips/{trip_id}/links' do
    parameter name: :trip_id, in: :path, type: :string, description: 'Trip ID'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    post 'Creates a link' do
      tags 'Links'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :link, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'My Link' },
          url: { type: :string, example: 'http://example.com' }
        },
        required: %w[title url]
      }

      response '201', 'link created' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:link) { { title: 'My Link', url: 'http://example.com' } }
        let(:trip_id) { trip.id }

        schema type: :object,
               properties: {
                 link_id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['link_id']).not_to be_nil
        end
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:link) { { title: 'My Link', url: 'http://example.com' } }
        let(:trip_id) { trip.id }

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
        let(:link) { { title: 'My Link' } }
        let(:trip_id) { trip.id }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Url can't be blank" } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:link) { { title: 'My Link', url: 'http://example.com' } }
        let(:trip_id) { trip.id }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/links/{id}' do
    parameter name: :id, in: :path, type: :string, description: 'Link ID'
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    delete 'Deletes a link' do
      tags 'Links'
      produces 'application/json'

      response '204', 'link deleted' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:participant) { create(:participant, trip: trip, user: user) }
        let(:link) { create(:link, trip: trip) }
        let(:id) { link.id }

        run_test!
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:link) { create(:link, trip: trip) }
        let(:id) { link.id }

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

      response '404', 'link not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'link with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end
end
