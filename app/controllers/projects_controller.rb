class ProjectsController < ApplicationController

  helper_method :sort_column, :sort_direction
  include DateFormats

  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  protect_from_forgery


  # GET /projects
  def index
    @projects = Project.joins("LEFT OUTER JOIN clients ON clients.id = projects.client_id ").filter(params,@per_page).order("#{sort_column} #{sort_direction}")
  end

  # GET /projects/1
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  def sort_column
    params[:sort] ||= 'created_at'
    Project.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end


  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params[:project]
    end
end
