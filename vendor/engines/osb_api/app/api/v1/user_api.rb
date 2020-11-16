module V1
  class UserApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl
    #prefix :api
    resource :users do
      before {current_user unless route.settings[:description][:description].eql?('Forgot Password')}

      desc 'Fetch All Users',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get do
        User.all
      end

      desc 'Fetch Current User',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get 'current_user' do
        @current_user
      end

      desc 'Fetch Single User',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      get ':id' do
        user = User.find_by(id: params[:id])
        user.present? ? user : {error: 'User not found', message: nil}
      end

      desc 'Change user Password',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :current_password, type: String, message: :required
        requires :password, type: String, message: :required
        requires :password_confirmation, type: String, message: :required
      end
      patch ':id/change_password' do
        user = User.find_by(id: params[:id])
        if !user.present?
          {error: "User not found", message: nil }
        else
          if user.update_with_password(current_password: params[:current_password], password: params[:password], password_confirmation: params[:password_confirmation])
            {message: "Password Updated"}
          else
            {error: user.errors.full_messages, message: nil }
          end
        end
      end

      desc 'Forgot Password'
      params do
        requires :email, type: String, message: :required
      end

      post 'forgot_password' do
        user = User.find_by(email: params[:email])
        if !user.present?
          {error: "No user found with this email", message: nil }
        else
          if User.send_reset_password_instructions(user)
            {message: "Email sent to reset password"}
          end
        end
      end

    end
  end
end



