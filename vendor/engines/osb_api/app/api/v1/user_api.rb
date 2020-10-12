module V1
  class UserApi < Grape::API
    version 'v1', using: :path, vendor: 'osb'
    format :json
    formatter :json, Grape::Formatter::Rabl
    #prefix :api
    resource :users do
      before {current_user}

      desc 'All Users',
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
    end
  end
end



