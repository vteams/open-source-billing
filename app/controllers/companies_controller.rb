class CompaniesController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  before_filter :set_per_page_session
  helper_method :sort_column, :sort_direction
  include CompaniesHelper
  # GET /companies
  # GET /companies.json
  def index
    params[:status] = params[:status] || 'active'
    @status = params[:status]
    @companies = Company.filter(params.merge(per: @per_page, account: current_user.current_account)).order(sort_column + " " + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @companies }
      format.js
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @company }
    end
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = current_user.current_account.companies.new(company_params)

    respond_to do |format|
      if @company.save
        if params[:select_new].to_i == 1
          session['current_company'] = @company.id
          current_user.update_attributes(current_company: @company)
        end
        format.js { @companies = Company.all }
        format.html { redirect_to companies_path, notice: t('views.companies.create_msg') }
        format.json { render json: companies_path, status: :created, location: @company }
      else
        format.js {}
        format.html { redirect_to companies_path, alert: @company.errors.full_messages.join('. ') }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(company_params)
        format.html { redirect_to params[:setting_form] == '1' ? settings_path : companies_path,
                                  notice: t('views.companies.updated_msg') }
        format.json { head :no_content }
      else
        format.js {}
        format.html { redirect_to companies_path, alert: @company.errors.full_messages.join('. ') }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    check_if_current_company
    if @flag_current_company
      user_message = t('views.companies.current_company_action', action: @action_for_company)
      redirect_to companies_path, alert: user_message
      return
    end
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to companies_path }
      format.json { render_json(@company) }
    end
  end

  def check_if_current_company
    if params[:id].eql?(get_user_current_company.id.to_s)
      if params[:archive].present?
        @action_for_company = "archived"
      else
        @action_for_company = "deleted"
      end
      @flag_current_company = true
    end
  end

  def filter_companies
    @companies = Company.filter(params.merge(per: session["#{controller_name}-per_page"], account: current_user.current_account)).order(sort_column + " " + sort_direction)
    respond_to { |format| format.js }
  end

  def bulk_actions
    if params[:company_ids].include? get_user_current_company.id.to_s
      if params[:archive].present?
        @action_for_company = "archived"
      else
        @action_for_company = "deleted"
      end
      @flag_current_company = true
      redirect_to companies_path, alert: t('views.companies.current_company_action', action: @action_for_company)
    else
      result = Services::CompanyBulkActionsService.new(params.merge({current_user: current_user})).perform
      @companies = result[:companies]
      @message = get_intimation_message(result[:action_to_perform], result[:company_ids])
      @action = result[:action]
      redirect_to companies_path, notice: t('views.companies.bulk_action_msg', action: @action)
    end
  end

  def undo_actions
    params[:archived] ? Company.recover_archived(params[:ids]) : Company.recover_deleted(params[:ids])
    @companies = current_user.current_account.companies.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])

    respond_to { |format| format.js }
  end

  def select
    session['current_company'] = params[:id]
    current_user.update_attributes(current_company: params[:id])
    company =  Company.find(params[:id])
    render :text => company.company_name
  end

  def settings_listing
    @companies = Company.all
    render layout: false
  end

  def destroy_bulk
    company = Company.where(id: params[:company_ids]).destroy_all

    @companies = Company.all
    render json: {notice: t('views.companies.deleted_msg'),
                  html: render_to_string(action: :settings_listing, layout: false)}
  end

  private

  def get_intimation_message(action_key, company_ids)
    helper_methods = {archive: 'companies_archived', destroy: 'companies_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, company_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort].present? ? params[:sort] : 'created_at'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def company_params
    params.require(:company).permit(:account_id, :city, :company_name, :company_tag_line, :contact_name, :contact_title, :country, :email, :fax_number, :logo, :memo, :phone_number, :postal_or_zipcode, :province_or_state, :street_address_1, :street_address_2)
  end

end
