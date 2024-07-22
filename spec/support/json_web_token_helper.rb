module JsonWebTokenHelper
  def generate_jwt(user)
    private_key_base64 = Rails.application.credentials.dig(:test, :jwt_priv_key)
    private_key = OpenSSL::PKey::RSA.new(Base64.decode64(private_key_base64))
    payload = { sub: user.external_id }
    JWT.encode(payload, private_key, 'RS256')
  end
end
