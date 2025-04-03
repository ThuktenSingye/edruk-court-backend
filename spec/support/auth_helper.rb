# frozen_string_literal: true

module AuthHelper
  def auth_headers(user)
    payload = {
      sub: user.id,
      jti: user.jti,
      exp: 15.minutes.from_now.to_i
    }

    secret = Rails.application.credentials.devise_jwt_secret_key
    token = JWT.encode(payload, secret, 'HS256')
    { 'Authorization' => "Bearer #{token}" }
  end
end
