class EstimatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_per_page_session
  protect_from_forgery
  helper_method :sort_column, :sort_direction
  include DateFormats

  layout :choose_layout
  include EstimatesHelper

  def index
    params[:status] = params[:status] || 'active'
    @estimates = Estimate.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ").filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @estimates = filter_by_company(@estimates)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def filter_estimates
    @estimates = Estimate.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @estimates = filter_by_company(@estimates)
  end

  def show
    @estimate = Estimate.find(params[:id])
    @client = Client.unscoped.find_by_id @estimate.client_id
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @estimate = Services::EstimateService.build_new_estimate(params)
    @client = Client.find params[:estimate_for_client] if params[:estimate_for_client].present?
    @client = @estimate.client if params[:id].present?
    @estimate.currency = @client.currency if @client.present?
    get_clients_and_items
    @discount_types = @estimate.currency.present? ? ['%', @estimate.currency.unit] : DISCOUNT_TYPE
    respond_to do |format|
      format.html # new.html.erb
      format.js
      #format.json { render :json => @invoice }
    end
  end

  def create
    @estimate = Estimate.new(estimate_params)
    @estimate.status = params[:save_as_draft] ? 'draft' : 'sent'
    @estimate.company_id = get_company_id()
    @estimate.create_line_item_taxes()
    respond_to do |format|
      if @estimate.save
        @estimate.notify(current_user, @estimate.id)  if params[:commit].present?
        new_estimate_message = new_estimate(@estimate.id, params[:save_as_draft])
        redirect_to(edit_estimate_url(@estimate), :notice => new_invoice_message)
        return
      else
        format.html { render :action => 'new' }
        format.json { render :json => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @estimate = Estimate.find(params[:id])
    @estimate.estimate_line_items.build()
    get_clients_and_items
    @discount_types = @estimate.currency.present? ? ['%', @estimate.currency.unit] : DISCOUNT_TYPE
    respond_to {|format| format.js; format.html}
  end

  def update
    @estimate = Estimate.find(params[:id])
    @estimate.company_id = get_company_id()
    notify = params[:commit].present? ? true : false
    respond_to do |format|
      if @estimate.update_attributes(estimate_params)
        @estimate.update_line_item_taxes()
        @estimate.notify(current_user, @estimate.id) if params[:commit].present?
        format.json { head :no_content }
        redirect_to({:action => "edit", :controller => "estimates", :id => @estimate.id}, :notice => 'Your Estimate has been updated successfully.')
        return
      else
        format.html { render :action => "edit" }
        format.json { render :json => @estimate.errors, :status => :unprocessable_entity }
      end
    end
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    Estimate.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def selected_currency
    @currency = Currency.find params[:currency_id]
  end
  private

  def estimate_params
    params.require(:estimate).permit(:client_id, :discount_amount, :discount_type,
                                    :discount_percentage, :estimate_date, :estimate_number,
                                    :notes, :po_number, :status, :sub_total, :tax_amount, :terms,
                                    :estimate_total, :estimate_line_items_attributes, :archive_number,
                                    :archived_at, :deleted_at, :company_id,:currency_id,
                                    estimate_line_items_attributes:
                                        [
                                            :id, :estimate_id, :item_description, :item_id, :item_name,
                                            :item_quantity, :item_unit_cost, :tax_1, :tax_2, :_destroy
                                        ]
    )
  end

end