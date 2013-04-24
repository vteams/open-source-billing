class SubUsersController < ApplicationController
  def index
    @sub_users = User.all
  end

  def new
  end

  def create
    sub_user = User.new({user_name: params[:user_name], email: params[:email],
                         password: params[:password],
                         password_confirmation: params[:password_confirmation]
                        })

    # skip email confirmation for login
    sub_user.skip_confirmation!

    # assign current user's company to newly created user
    current_user.companies.first.users << sub_user

    respond_to do |format|
      if sub_user.already_exists?(params[:email])
        redirect_to(new_sub_user_path, alert: 'User with same email already exists.')
        return
      elsif sub_user.save
        UserMailer.new_user_account(current_user, sub_user).deliver if params[:notify_user]
        redirect_to(edit_sub_user_url(sub_user), notice: 'User has been saved successfully')
        return
      else
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @sub_user = User.find_by_id(params[:id])
  end

  def update
    sub_user = User.find(params[:id])
    respond_to do |format|
      options = {user_name: params[:user_name], email: params[:email],
                 password: params[:password], password_confirmation: params[:password]}

      # don't update password if not provided
      if params[:password].blank?
        options.delete(:password)
        options.delete(:password_confirmation)
      end

      message = if sub_user.update_attributes(options)
                  {notice: 'User has been updated successfully'}
                else
                  {alert: 'User can not be updated'}
                end

      redirect_to(edit_sub_user_url(sub_user), message)
      return
    end
  end

  def destroy
    sub_user = User.find_by_id(params[:id]).destroy
    respond_to { |format| format.js }
  end
end
