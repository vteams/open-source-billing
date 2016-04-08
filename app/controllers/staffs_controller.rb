class StaffsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :set_per_page_session
  before_action :set_staff, only: [:show, :edit, :update, :destroy]
  include StaffsHelper

  # GET /staffs
  def index
    set_company_session
    params[:status] = params[:status] || 'active'
    @staffs = Staff.filter(params.merge(per: @per_page)).order(sort_column + " " + sort_direction)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: staffs }
      format.js
    end
  end

  # GET /staffs/1
  def show
    redirect_to edit_staff_path
  end

  # GET /staffs/new
  def new
    @staff = Staff.new
  end

  # GET /staffs/1/edit
  def edit
  end

  # POST /staffs
  def create
    company_id = session['current_company'] || current_user.current_company || current_user.first_company_id
    if Staff.is_exists?(params[:staff][:email], company_id)
      @staff_exists = true
      redirect_to(new_staff_path, :alert => "Staff with same email already exists") unless params[:quick_create]
      return
    end
    @staff = Staff.new(staff_params)
    options = params[:quick_create] ? params.merge(company_ids: company_id) : params
    associate_entity(options, @staff)
    respond_to do |format|
      if @staff.save
        format.js
        format.json { render :json => @staff, :status => :created, :location => @staff }
        redirect_to @staff, notice: 'Staff was successfully created.' unless params[:quick_create]
        return
      else
        format.js
        format.html { render :action => "new" }
        format.json { render :json => @staff.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /staffs/1
  def update
    if @staff.update(staff_params)
      redirect_to @staff, notice: 'Staff was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /staffs/1
  def destroy
    @staff.destroy
    redirect_to staffs_url, notice: 'Staff was successfully destroyed.'
  end

  def filter_staffs
    @staffs = Staff.filter(params.merge(per: session["#{controller_name}-per_page"])).order(sort_column + " " + sort_direction)
    respond_to { |format| format.js }
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def bulk_actions
    params[:sort] = params[:sort] || 'created_at'
    result = Services::StaffBulkActionsService.new(params.merge({current_user: current_user})).perform
    @staffs = result[:staffs]
    @message = get_intimation_message(result[:action_to_perform], result[:staff_ids])
    @action = result[:action]
    #end
    respond_to { |format| format.js }
  end

  def undo_actions
    params[:archived] ? Staff.recover_archived(params[:ids]) : Staff.recover_deleted(params[:ids])
    @staffs = Staff.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    respond_to { |format| format.js }
  end

  def load_staff_data
    staff = Staff.find_by_id(params[:id]).present? ?  Staff.find(params[:id]) : Staff.unscoped.find_by_id(params[:id])
    render :text => [staff.email , staff.rate, staff.name]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff
      @staff = Staff.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def staff_params
      params.require(:staff).permit(:email, :name, :rate, :created_by, :updated_by)
    end

  def get_intimation_message(action_key, staff_ids)
    helper_methods = {archive: 'staffs_archived', destroy: 'staffs_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, staff_ids) : nil
  end
  def sort_column
    params[:sort] ||= 'created_at'
    sort_col = params[:sort]
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
