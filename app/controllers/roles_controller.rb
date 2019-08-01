class RolesController < ApplicationController

  before_action :set_role, only: %i[show edit update destroy]

  def index
    @roles = Role.all
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    respond_to do |format|
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @role.update(role_params)
        format.js
      end
    end
  end

  def destroy
    @role.destroy
    if @role.destroy
      redirect_to roles_url
    end
  end

  private

  def role_params
    params.require(:role).permit(:name)
  end

  def set_role
    @role = Role.find(params[:id])
  end
end
