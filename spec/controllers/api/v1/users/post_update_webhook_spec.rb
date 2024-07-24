require 'rails_helper'

describe Api::V1::UsersController do
  describe 'POST #update_webhook' do
    let(:authorization) { { 'Authorization' => "Bearer #{generate_jwt(user)}" } }
    let(:user) { create(:user) }

    context '' do
      let(:new_attributes) do
        { data: {
          id: user.external_id,
          first_name: 'Joao',
          last_name: 'silva',
          email_addresses: [{ email_address: 'jonh@gmail.com' }],
          public_metadata: { participant_email: 'jonh@gmail.com' }
        } }
      end

      it 'return success' do
        request.headers.merge!(authorization)
        partcipant = create :participant, email: 'jonh@gmail.com'

        post :update_webhook, params: new_attributes, format: :json

        user = User.last
        expect(response).to have_http_status(:no_content)
        expect(user).to be_truthy
        expect(user.name).to eq('Joao silva')
        expect(user.participants).to include(partcipant)
      end
    end
  end
end
