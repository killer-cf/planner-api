require 'swagger_helper'

RSpec.describe 'api/v1/trips', type: :request do
  let(:user) { create(:user) }

  path '/api/v1/trips' do
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
    get 'Retrieves all trips' do
      tags 'Trips'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, description: 'Page number', required: false
      parameter name: :per_page, in: :query, type: :integer, description: 'Items per page', required: false

      response '200', 'trips found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let!(:trips) { create_list(:trip, 5) { |trip| create(:participant, user:, trip:) } }

        schema type: :object,
               properties: {
                 trips: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                       destination: { type: :string, example: 'Paris' },
                       starts_at: { type: :string, format: 'date' },
                       ends_at: { type: :string, format: 'date' }
                     }
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trips'].size).to eq(5)
        end
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end
    end

    post 'Creates a trip' do
      tags 'Trips'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :trip, in: :body, schema: {
        type: :object,
        properties: {
          destination: { type: :string, example: 'Paris' },
          starts_at: { type: :string, format: 'date-time' },
          ends_at: { type: :string, format: 'date-time' },
          owner_name: { type: :string, example: 'John Doe' },
          owner_email: { type: :string, format: 'email', example: 'jonhdoe@gmail.com' }
        },
        required: %w[destination starts_at ends_at owner_name owner_email]
      }

      response '201', 'trip created' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) do
          { destination: 'Paris', starts_at: '2023-12-01T00:00:00Z', ends_at: '2023-12-10T00:00:00Z', owner_name: 'John Doe',
            owner_email: 'john@example.com' }
        end

        schema type: :object,
               properties: {
                 trip_id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trip_id']).not_to be_nil
        end
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { { destination: 'Paris' } }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Owner name can't be blank" } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:trip) do
          { destination: 'Paris', starts_at: '2023-12-01T00:00:00Z', ends_at: '2023-12-10T00:00:00Z', owner_name: 'John Doe',
            owner_email: 'john@example.com' }
        end

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'trip found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let!(:participant) { create(:participant, user: user, trip: trip, is_owner: true) }
        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                 destination: { type: :string, example: 'Paris' },
                 starts_at: { type: :string, format: 'date-time', example: '2023-12-01T00:00:00Z' },
                 ends_at: { type: :string, format: 'date-time', example: '2023-12-10T00:00:00Z' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['trip']['id']).to eq(trip.id)
        end
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

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end

    put 'Updates a trip' do
      tags 'Trips'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :trip_params, in: :body, schema: {
        type: :object,
        properties: {
          destination: { type: :string, example: 'Paris' },
          starts_at: { type: :string, format: 'date-time' },
          ends_at: { type: :string, format: 'date-time' }
        },
        required: %w[destination starts_at ends_at]
      }

      response '200', 'trip updated' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, trip: trip, user: user, is_owner: true) }
        let(:trip_params) do
          { destination: 'Recife, Brazil', starts_at: '2023-12-01T00:00:00Z', ends_at: '2023-12-10T00:00:00Z' }
        end

        schema type: :object,
               properties: {
                 id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                 destination: { type: :string, example: 'Recife, Brazil' },
                 starts_at: { type: :string, format: 'date-time', example: '2023-12-01T00:00:00Z' },
                 ends_at: { type: :string, format: 'date-time', example: '2023-12-10T00:00:00Z' }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:id) { 'invalid' }
        let(:trip_params) do
          { destination: 'Recife, Brazil', starts_at: '2023-12-01T00:00:00Z', ends_at: '2023-12-10T00:00:00Z' }
        end

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }
        let(:trip_params) do
          { destination: 'Recife, Brazil', starts_at: '2023-12-01T00:00:00Z', ends_at: '2023-12-10T00:00:00Z' }
        end

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end

    delete 'Deletes a trip' do
      tags 'Trips'

      response '204', 'trip deleted' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, user: user, trip: trip, is_owner: true) }

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

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/activities' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves activities for a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'activities found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, user: user, trip: trip) }

        schema type: :object,
               properties: {
                 activities: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                       title: { type: :string, example: 'Visit Eiffel Tower' },
                       occurs_at: { type: :string, format: 'date-time', example: '2023-12-02T10:00:00Z' }
                     }
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['activities']).not_to be_empty
        end
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

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/links' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves links for a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'links found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, user: user, trip: trip) }

        schema type: :object,
               properties: {
                 links: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                       url: { type: :string, example: 'https://example.com' },
                       title: { type: :string, example: 'Link to itinerary' }
                     }
                   }
                 }
               }

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

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/participants' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves participants for a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'participants found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let!(:participant) { create(:participant, user: user, trip: trip) }
        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 participants: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                       name: { type: :string, example: 'John Doe' },
                       email: { type: :string, format: 'email', example: 'john@example.com' },
                       is_owner: { type: :boolean, example: true },
                       is_confirmed: { type: :boolean, example: true }
                     }
                   }
                 }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).not_to be_empty
        end
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

      response '404', 'trip not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Trip with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/invites' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    post 'Invites a participant to a trip' do
      tags 'Trips'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :invite, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: 'email', example: 'invitee@example.com' },
          name: { type: :string, example: 'Joao' }
        },
        required: %w[email]
      }

      response '200', 'participant invited' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, user: user, trip: trip, is_owner: true) }
        let(:invite) { { email: 'invitee@example.com', name: 'Invitee' } }

        schema type: :object,
               properties: {
                 participant_id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['participant_id']).not_to be_nil
        end
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let!(:participant) { create(:participant, user: user, trip: trip, is_owner: true) }
        let(:id) { trip.id }
        let(:invite) { { email: '', name: 'Invitee' } }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Email can't be blank" } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:id) { 'invalid' }
        let(:invite) { { email: 'invitee@example.com', name: 'Invitee' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end

      response '403', 'forbidden' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let(:id) { trip.id }
        let!(:participant) { create(:participant, user: user, trip: trip) }
        let(:invite) { { email: 'invitee@example.com', name: 'Invitee' } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Forbidden' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/trips/{id}/current_participant' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves the current participant for a trip' do
      tags 'Trips'
      produces 'application/json'

      response '200', 'current participant found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:trip) { create(:trip) }
        let!(:participant) { create(:participant, user: user, trip: trip) }
        let(:id) { trip.id }

        schema type: :object,
               properties: {
                 id: { type: :uuid, example: '123e4567-e89b-12d3-a456-426614174000' },
                 name: { type: :string, example: 'John Doe' },
                 email: { type: :string, format: 'email', example: 'john@example.com' },
                 is_owner: { type: :boolean, example: true },
                 is_confirmed: { type: :boolean, example: true }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).not_to be_empty
        end
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

      response '404', 'participant not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Participant not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end
end
