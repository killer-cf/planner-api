module JsonWebToken
  extend ActiveSupport::Concern

  def jwt_decode(token)
    public_key_base64 = Rails.application.credentials.dig(Rails.env.to_sym, :jwt_pub_key)
    if public_key_base64.nil?
      Rails.logger.error 'JWT public key not found in credentials'
      return nil
    end
    public_key = OpenSSL::PKey::RSA.new(Base64.decode64(public_key_base64))

    body = JWT.decode(token, public_key, true, { algorithm: 'RS256' })[0]
    ActiveSupport::HashWithIndifferentAccess.new body
  rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError => e
    Rails.logger.error e.message
    nil
  end
end
