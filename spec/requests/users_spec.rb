require 'swagger_helper'

RSpec.describe 'api/v1/users', type: :request do
  let(:user) { create(:user) }

  path '/api/v1/users/{id}' do
    parameter name: :id, in: :path, type: :string
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'

    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'

      response '200', 'user found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { user.external_id }

        schema type: :object,
               properties: {
                 id: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' },
                 name: { type: :string, example: 'John Doe' },
                 email: { type: :string, example: 'john.doe@example.com' },
                 trip_ids: { type: :array, items: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' } }
               }

        run_test!
      end

      response '401', 'unauthorized' do
        let(:authorization) { nil }
        let(:id) { user.external_id }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               },
               required: ['error']

        run_test!
      end

      response '404', 'user not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:id) { 'invalid' }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'User with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end

  path '/api/v1/users/create_webhook' do
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
    parameter name: :data, in: :body, schema: {
      type: :object,
      properties: {
        data: {
          type: :object,
          properties: {
            first_name: { type: :string, example: 'John' },
            last_name: { type: :string, example: 'Doe' },
            email_addresses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  email_address: { type: :string, example: 'john.doe@example.com' }
                }
              }
            },
            id: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' },
            public_metadata: {
              type: :object,
              properties: {
                participant_email: { type: :string, example: 'participant@example.com' }
              }
            }
          }
        }
      },
      required: ['data']
    }

    post 'Creates a user via webhook' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      response '204', 'user created' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) do
          {
            data: {
              first_name: 'John',
              last_name: 'Doe',
              email_addresses: [{ email_address: 'john.doe@example.com' }],
              id: '123e4567-e89b-12d3-a456-426614174000',
              public_metadata: { participant_email: 'participant@example.com' }
            }
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) { { data: { first_name: 'John', id: user.external_id } } }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Email can't be blank" } }
               }

        run_test!
      end
    end
  end

  path '/api/v1/users/update_webhook' do
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
    parameter name: :data, in: :body, schema: {
      type: :object,
      properties: {
        data: {
          type: :object,
          properties: {
            first_name: { type: :string, example: 'John' },
            last_name: { type: :string, example: 'Doe' },
            email_addresses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  email_address: { type: :string, example: 'john.doe@example.com' }
                }
              }
            },
            id: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' },
            public_metadata: {
              type: :object,
              properties: {
                participant_email: { type: :string, example: 'participant@example.com' }
              }
            }
          }
        }
      },
      required: ['data']
    }

    post 'Updates a user via webhook' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      response '204', 'user updated' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) do
          {
            data: {
              first_name: 'John',
              last_name: 'Doe',
              email_addresses: [{ email_address: 'john.doe@example.com' }],
              id: user.external_id,
              public_metadata: { participant_email: 'participant@example.com' }
            }
          }
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) { { data: { first_name: 'John', id: user.external_id } } }

        schema type: :object,
               properties: {
                 errors: { type: :array, items: { type: :string, example: "Email can't be blank" } }
               }

        run_test!
      end
    end
  end

  path '/api/v1/users/destroy_webhook' do
    parameter name: :authorization, in: :header, type: :string, default: 'Bearer <token>'
    parameter name: :data, in: :body, schema: {
      type: :object,
      properties: {
        data: {
          type: :object,
          properties: {
            id: { type: :string, example: '123e4567-e89b-12d3-a456-426614174000' }
          }
        }
      },
      required: ['data']
    }

    post 'Destroys a user via webhook' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      response '204', 'user destroyed' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) { { data: { id: user.external_id } } }

        run_test!
      end

      response '404', 'user not found' do
        let(:authorization) { "Bearer #{generate_jwt(user)}" }
        let(:data) { { data: { id: 'invalid' } } }

        schema type: :object,
               properties: {
                 error: { type: :string, example: 'User with id: invalid not found' }
               },
               required: ['error']

        run_test!
      end
    end
  end
end
