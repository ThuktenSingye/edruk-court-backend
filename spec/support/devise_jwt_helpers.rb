# frozen_string_literal: true

module DeviseJwtHelpers
  def jwt_for(user)
    # If using Warden-JWT-Auth (recommended)
    if defined?(Warden::JWTAuth::UserEncoder)
      Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    else
      # Fallback: Manual JWT generation (if Warden-JWT-Auth is not available)
      secret_key = Rails.application.credentials.devise_jwt_secret_key || 'fallback_secret'
      payload = { sub: user.id, jti: SecureRandom.uuid }
      JWT.encode(payload, secret_key, 'HS256')
    end
  end
end
