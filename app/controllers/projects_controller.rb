class ProjectsController < ApplicationController
  helper_method :sort_column, :sort_direction

  layout :choose_layout
  include ProjectsHelper

  include DateFormats

  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  protect_from_forgery


  # GET /projects
  def index
    params[:status] = params[:status] || 'active'
    @status = params[:status]
    load_projects
    @projects = filter_by_company(@projects) if @projects
    authorize @projects
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /projects/1
  def show
    @status = @project.deleted_at.present? ? 'deleted' : ( @project.archived? ? 'archived?' : 'active' )
    params[:status] = params[:status] || 'active'
    load_projects
    @project_logs = @project.logs.order('date desc')
    @project_tasks = @project.project_tasks.order('updated_at desc').page(params[:page]).per(@per_page)
  end

  # GET /projects/new
  def new
    managers = load_managers_for_project('new', get_company_id, nil)
    redirect_to staffs_path, alert: t('views.projects.staff_required_msg') and return if managers.count <= 0
    params[:status] = params[:status] || 'active'
    @status = params[:status]
    load_projects
    @projects = filter_by_company(@projects)
    @project = Project.new
    3.times { @project.project_tasks.build(); @project.team_members.build() }
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # GET /projects/1/edit
  def edit
    3.times { @project.project_tasks.build() } if @project.project_tasks.blank?
    3.times { @project.team_members.build() } if @project.team_members.blank?
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  # POST /projects
  def create
    if Project.is_exists?(params[:project][:project_name])
      @project_exists = true
    else
      @project = Project.new(project_params)
      @project.company_id = get_company_id
      @project.save
    end
  end

  # PATCH/PUT /projects/1
  def update
    @project.update(project_params)
  end

  # DELETE /projects/1
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url, notice: t('views.projects.destroyed_msg') }
      format.json { render_json(@project) }
    end
  end

  def sort_column
    params[:sort] ||= 'created_at'
    Project.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def bulk_actions
    result = Services::ProjectService.perform_bulk_action(params.merge({current_user: current_user}))
    @projects = filter_by_company(result[:projects]).order("#{sort_column} #{sort_direction}")
    @project_has_deleted_clients = project_has_deleted_clients?(@projects)
    @message = get_intimation_message(result[:action_to_perform], result[:project_ids])
    @action = result[:action]
    redirect_to projects_path, notice: t('views.projects.bulk_action_msg', action: @action)
  end

  def undo_actions
    params[:archived] ? Project.recover_archived(params[:ids]) : Project.recover_deleted(params[:ids])
    @projects = Project.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    @projects = filter_by_company(@projects).order("#{sort_column} #{sort_direction}")
    respond_to { |format| format.js }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def project_params
      params.require(:project).permit(:project_name, :description, :client_id, :manager_id, :billing_method,
                                      :total_hours, :company_id,:project_tasks_attributes,:team_members_attributes,
                                      project_tasks_attributes:
                                      [
                                        :id, :task_id, :name, :description, :rate, :project_id, :_destroy
                                      ],
                                      team_members_attributes:
                                      [
                                        :id, :staff_id, :email, :name, :rate, :project_id, :_destroy
                                      ]
      )
    end

  def get_company_id
    session['current_company'] || current_user.current_company || current_user.first_company_id
  end

  def project_has_deleted_clients?(projects)
    project_with_deleted_clients = []
    projects.each do |project|
      if project.unscoped_client.present? && project.unscoped_client.deleted_at.present?
        project_with_deleted_clients << project.project_name
      end
    end
    project_with_deleted_clients
  end

    def get_intimation_message(action_key, invoice_ids)
    helper_methods = {archive: 'projects_archived', destroy: 'projects_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, invoice_ids) : nil
  end

  def load_projects
    # if (current_user.has_role? :staff)
    #   projects = current_user.staff.projects if current_user.staff.present?
    # else
    #   projects = Project.joins("LEFT OUTER JOIN clients ON clients.id = projects.client_id ")
    # end

    # if projects
    #   projects = ((current_user.has_role? :staff) && current_user.staff ) ? current_user.staff.projects : Project.joins("LEFT OUTER JOIN clients ON clients.id = projects.client_id ")
    #   projects = projects.search(params[:search]).records if params[:search].present?
    #   projects = projects.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    # else
    #   projects = nil
    # end

    @projects = Project.all
  end

end
