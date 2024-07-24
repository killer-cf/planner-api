require 'rails_helper'

describe Api::V1::UsersController do
  describe 'POST #create_webhook' do
    context '' do
      let(:new_attributes) do
        { data: {
          id: 'an_external_id',
          first_name: 'Joao',
          last_name: 'silva',
          email_addresses: [{ email_address: 'jonh@gmail.com' }],
          public_metadata: {}
        } }
      end

      it 'return success' do
        post :create_webhook, params: new_attributes, format: :json

        user = User.last
        expect(response).to have_http_status(:no_content)
        expect(user).to be_truthy
        expect(user.name).to eq('Joao silva')
        expect(user.email).to eq('jonh@gmail.com')
        expect(user.external_id).to eq('an_external_id')
      end
    end
  end
end
