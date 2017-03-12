class TaxesController < ApplicationController
  authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  before_filter :set_per_page_session
  helper_method :sort_column, :sort_direction
  # GET /taxes
  # GET /taxes.json
  include TaxesHelper

  def index
    params[:status] = params[:status] || 'active'
    mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}
    method = mappings[params[:status].to_sym]

    @taxes = Tax.send(method).page(params[:page]).per(@per_page).order(sort_column + " " + sort_direction)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      #format.json { render json: @taxes }
    end
  end

  # GET /taxes/1
  # GET /taxes/1.json
  def show
    @taxis = Tax.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @taxis }
    end
  end

  # GET /taxes/new
  # GET /taxes/new.json
  def new
    @taxis = Tax.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @taxis }
    end
  end

  # GET /taxes/1/edit
  def edit
    @taxis = Tax.find(params[:id])
  end

  # POST /taxes
  # POST /taxes.json
  def create
    if Tax.is_exits?(params[:tax][:name])
      @tax_exists = true
      redirect_to(new_tax_path, :alert => "Tax with same name already exists") unless params[:quick_create]
      return
    end
    @taxis = Tax.new(taxes_params)

    respond_to do |format|
      if @taxis.save
        format.js
        format.html { redirect_to @taxis, notice: 'Tax was successfully created.' }
        format.json { render json: @taxis, status: :created, location: @taxis }
        new_tax_message = new_tax(@taxis.id)
        redirect_to({:action => "edit", :controller => "taxes", :id => @taxis.id}, :notice => new_tax_message) unless params[:quick_create]
        return
      else
        format.html { render action: "new" }
        format.json { render json: @taxis.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /taxes/1
  # PUT /taxes/1.json
  def update
    @taxis = Tax.find(params[:id])

    respond_to do |format|
      if @taxis.update_attributes(taxes_params)
        format.html { redirect_to taxes_url, notice: 'Tax was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @taxis.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxes/1
  # DELETE /taxes/1.json
  def destroy
    @taxis = Tax.find(params[:id])
    @taxis.destroy

    respond_to do |format|
      format.html { redirect_to taxes_url }
      format.json { head :no_content }
    end
  end

  def bulk_actions
    result = Services::TaxBulkActionsService.new(params.merge({current_user: current_user})).perform
    @taxes = result[:taxes].order("#{sort_column} #{sort_direction}")
    @message = get_intimation_message(result[:action_to_perform], result[:tax_ids])
    @action = result[:action]
    respond_to { |format| format.js }
  end

  def filter_taxes
    @taxes = Tax.filter(params,session["#{controller_name}-per_page"]).order("#{sort_column} #{sort_direction}")
  end

  def undo_actions
    params[:archived] ? Tax.recover_archived(params[:ids]) : Tax.recover_deleted(params[:ids])
    @taxes = Tax.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    respond_to { |format| format.js }
  end

  private

  def get_intimation_message(action_key, tax_ids)
    helper_methods = {archive: 'taxes_archived', destroy: 'taxes_deleted'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, tax_ids) : nil
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    Tax.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def taxes_params
    params.require(:tax).permit(:name, :percentage, :archived_at, :archive_number, :deleted_at)
  end

end
