# frozen_string_literal: true

module ApplicationCable
  # Connection Class for Action Cable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = fetch_token
      decoded = decode_token(token)
      user_id = extract_user_id(decoded)
      find_user(user_id)
    end

    def fetch_token
      token = request.params[:token] || extract_bearer_token
      reject_unauthorized_connection unless token
      token
    end

    def decode_token(token)
      JWT.decode(token, ENV.fetch('DEVISE_JWT_SECRET_KEY', nil), true, algorithm: 'HS256').first
    rescue JWT::DecodeError
      reject_unauthorized_connection
    end

    def extract_user_id(decoded)
      user_id = decoded['id'] || decoded['user_id'] || decoded['sub']
      reject_unauthorized_connection unless user_id
      user_id
    end

    def find_user(user_id)
      User.find_by(id: user_id) || reject_unauthorized_connection
    end

    def extract_bearer_token
      return unless request.headers['Authorization']

      request.headers['Authorization'].split[1]
    end
  end
end
