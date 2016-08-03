class EstimatesController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  before_filter :authenticate_user!
  before_filter :set_per_page_session
  protect_from_forgery except: [:preview]
  before_filter :authenticate_user!, except: [:preview]
  helper_method :sort_column, :sort_direction
  include DateFormats

  layout :choose_layout
  include EstimatesHelper

  def index
    params[:status] = params[:status] || 'active'
    #@estimates = Estimate.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ").filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @estimates = Estimate.all.filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    #@estimates = filter_by_company(@estimates)
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
        redirect_to(edit_estimate_url(@estimate), :notice => new_estimate_message)
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

  def estimate_pdf
    # to be used in invoice_pdf view because it requires absolute path of image
    @images_path = "#{request.protocol}#{request.host_with_port}/assets"
    estimate_id = OSB::Util.decrypt(params[:id])
    @estimate = Estimate.find(estimate_id)
    respond_to do |format|
      format.pdf do
        file_name = "Estimate-#{Date.today.to_s}.pdf"
        pdf = render_to_string  pdf: "#{@estimate.estimate_number}",
                                layout: 'pdf_mode.html.erb',
                                encoding: "UTF-8",
                                template: 'estimates/estimate_pdf.html.erb',
                                footer:{
                                    right: 'Page [page] of [topage]'
                                }
        send_data pdf, filename: file_name
      end
    end
  end

  def send_estimate
    estimate = Estimate.find(params[:id])
    estimate.send_estimate(current_user, params[:id])
    redirect_to(estimate_path(estimate), notice: 'Estimate sent successfully.')
  end

  def bulk_actions
    result = Services::EstimateService.perform_bulk_action(params.merge({current_user: current_user}))
    @estimates = filter_by_company(result[:estimates]).order("#{sort_column} #{sort_direction}")
    @estimate_has_deleted_clients = estimate_has_deleted_clients?(@estimates)
    @message = get_intimation_message(result[:action_to_perform], result[:estimate_ids])
    @action = result[:action]
    respond_to { |format| format.js }
  end

  def undo_actions
    params[:archived] ? Estimate.recover_archived(params[:ids]) : Estimate.recover_deleted(params[:ids])
    @estimates = Estimate.unarchived_and_not_invoiced.page(params[:page]).per(session["#{controller_name}-per_page"])
    #filter invoices by company
    @estimates = filter_by_company(@estimates).order("#{sort_column} #{sort_direction}")
    respond_to { |format| format.js }
  end

  def convert_to_invoice
    estimate = Estimate.find(params[:id])
    estimate.convert_to_invoice
    redirect_to(estimate_path(estimate), notice: 'Estimate successfully converted to invoice.')
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

  def preview
    @estimate = Services::EstimateService.get_estimate_for_preview(params[:inv_id])
    render action: 'estimate_deleted_message', notice: "This estimate has been deleted." if @estimate == 'Estimate deleted'
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

  def estimate_has_deleted_clients?(estimates)
    estimate_with_deleted_clients = []
    estimates.each do |estimate|
      if estimate.unscoped_client.deleted_at.present?
        estimate_with_deleted_clients << estimate.estimate_number
      end
    end
    estimate_with_deleted_clients
  end

  def get_intimation_message(action_key, estimate_ids)
    helper_methods = {archive: 'estimates_archived', destroy: 'estimates_deleted', invoiced: 'convert_to_invoice'}
    helper_method = helper_methods[action_key.to_sym]
    helper_method.present? ? send(helper_method, estimate_ids) : nil
  end

end