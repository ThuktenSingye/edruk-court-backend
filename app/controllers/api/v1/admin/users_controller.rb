# frozen_string_literal: true

module Api
  module V1
    module Admin
      # User Controller
      class UsersController < BaseController
        before_action :user, only: %i[update show]

        def show
          authorize @user
          render_json :ok, nil, serialized_user(@user)
        end

        def create
          user = build_user
          authorize user
          if user.save
            render_json :created, 'User created successfully', serialized_user(user)
          else
            render_json :unprocessable_entity, nil, user.errors.as_json
          end
        end

        def update
          authorize @user
          if @user.update(user_params)
            render_json :ok, 'User updated successfully', serialized_user(@user)
          else
            render_json :unprocessable_entity, nil, @user.errors.as_json
          end
        end

        private

        def user
          @user ||= User.find(params[:id])
        end

        def build_user
          user = User.build(user_params.except(:role))
          user.add_role(user_params[:role]) if user_params[:role]
          user.confirmed_at = Time.zone.now
          user
        end

        def serialized_users(users)
          users.map do |user|
            UserSerializer.new(user).serializable_hash[:data][:attributes]
          end
        end

        def serialized_user(user)
          UserSerializer.new(user).serializable_hash[:data][:attributes]
        end

        # rubocop:disable Rails/StrongParametersExpect
        def user_params
          params.require(:user).permit(
            :email, :password, :password_confirmation, :court_id, :role,
            {
              profile_attributes: %i[
                first_name last_name cid_no phone_number
              ]
            }
          )
        end
        # rubocop:enable Rails/StrongParametersExpect
      end
    end
  end
end
