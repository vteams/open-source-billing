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
        User.find(params[:id])
      end

      desc 'Change user Password',
           headers: {
               "Access-Token" => {
                   description: "Validates your identity",
                   required: true
               }
           }
      params do
        requires :current_password, type: String
        requires :password, type: String
        requires :password_confirmation, type: String
      end
      patch ':id/change_password' do
        user = User.find params[:id]
        if user.update_with_password(current_password: params[:current_password], password: params[:password], password_confirmation: params[:password_confirmation])
          {message: "Password Updated"}
        else
          {error: user.errors.full_messages}
        end
      end

      desc 'Forgot Password'
      params do
        requires :email, type: String
      end

      post 'forgot_password' do
        u=User.find_by(email: params[:email])
        if User.send_reset_password_instructions(u)
          {message: "Email sent to reset password"}
        end
      end

    end
  end
end



