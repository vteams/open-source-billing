module Services
  module Apis
    class UserApiService

      def self.update(params)
        user = ::User.find(params[:id])
        if User.exists?(email: params[:user][:email]) && user.email != params[:user][:email]
          {error: 'User with same email already exists', message: nil }
        else
          if user.present?
            user.avatar = params[:user][:avatar] if params[:user][:avatar].present?
            if user.update_attributes(user_params_api(params))
              {message: 'Successfully updated'}
            else
              {error: user.errors.full_messages, message: nil }
            end
          end
        end
      end

      private

      def self.user_params_api(params)
        ActionController::Parameters.new(params).require(:user).permit(
          :email,
          :user_name,
          :password,
          :password_confirmation,
          :role_id,
          :avatar
          )
      end
    end
  end
end