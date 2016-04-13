class LogsController < ApplicationController
  include DateFormats
  before_action :set_log, only: [:show, :edit, :update, :destroy]
  layout 'application'
  protect_from_forgery

  def index
    @date = params[:date] || Date.today
    @logs = Log.where(date: @date).order(:created_at).page(params[:page]).per(10)
    @log = Log.new
    @tasks = []
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end

  end

  def new
    @log = Log.new
  end

  # GET /tasks/1/edit
  def edit
    @tasks = Project.find(@log.project_id).project_tasks
    @log.date = @log.date
    respond_to do |format|
      format.js
    end
  end

  # POST /tasks
  def create
    unless params[:form_for_week]   #creating log for single day
      @log = Log.new(log_params)
      if @log.save
        @logs = Log.where(date: @log.date).order(:created_at).page(params[:page]).per(10)
        respond_to do |format|
          format.html
          format.js
        end
      else
        render :index
      end
    else #creating bulk log for 1 week
      params[:time].each do |index,value|
        unless value == ''
          Log.create(project_id: params[:log][:project_id], task_id: params[:log][:task_id], hours: value, notes: nil, date: params[:day][index])
        end
      end
      @logs = Log.where('date BETWEEN ? AND ?', Date.parse(params[:day]['1']), Date.parse(params[:day]['7']) ).order(:created_at).page(params[:page]).per(10)
        respond_to do |format|
          format.html # index.html.erb
          format.js
        end
    end

  end

  # PATCH/PUT /tasks/1
  def update
    if @log.update(log_params)
      @logs = Log.where(date: @log.date).order(:created_at).page(params[:page]).per(10)
      @view = params[:view]
      @view == 'basicWeek' ? @form_type = 'form_week' : @form_type = 'form'; @date=@log.date
      @log = Log.new
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  # DELETE /tasks/1
  def destroy
    @log.destroy
    @logs = Log.where(date: @log.date).order(:created_at).page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def events
    @logs = Log.all.group(:date).sum(:hours)

    respond_to do |format|
      format.json
    end
  end

  def load_view
    @view = params[:view]
    @log = Log.new
    if @view == 'basicWeek'
      @form_type = 'form_week'
      @logs = Log.where('date BETWEEN ? AND ?', Date.parse(params[:date]), Date.parse(params[:date])  + 6 ).order(:created_at).page(params[:page]).per(10)
    else
      @form_type = 'form'
      @logs = Log.where(date: Date.today).order(:created_at).page(params[:page]).per(10)
    end
    respond_to do |format|
      format.js
    end
  end

  def update_tasks
    project_id = params[:project_id].to_i
    unless project_id == 0
      @tasks = Project.find(project_id).project_tasks
      respond_to do |format|
        format.js
      end
    end
  end

  def timer
    @log = Log.new
    respond_to do |format|
      format.html{ render layout: 'timer' }
      format.js
    end
  end

  def invoice
  end

  def invoice_form
    @project = Project.find(params[:project_id])
    @client = @project.client
    @invoice = Services::InvoiceService.build_new_project_invoice(@project)
    @discount_types = @invoice.currency.present? ? ['%', @invoice.currency.unit] : DISCOUNT_TYPE
  end

  def create_invoice
    @invoice = Invoice.new(invoice_params)
    @invoice.status = params[:save_as_draft] ? 'draft' : 'sent'
    @invoice.company_id = get_company_id()
    respond_to do |format|
      if @invoice.save
        Services::InvoiceService.create_invoice_tasks(@invoice)
        @invoice.notify(current_user, @invoice.id)  if params[:commit].present?
        redirect_to(invoice_url(@invoice), :notice => "Invoice successfully created")
        return
      else
        format.html { render :action => 'invoice_form' }
        format.json { render :json => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def set_log
    @log = Log.find(params[:id])
  end

  def log_params
    params.require(:log).permit(:project_id, :task_id, :hours, :notes, :date, :form_for_week)
  end

  def load_logs(log_date)
    date = log_date.to_datetime
    Log.where('date BETWEEN ? AND ?', date.beginning_of_day, date.end_of_day)
  end

  def invoice_params
    params.require(:invoice).permit(:client_id, :discount_amount, :discount_type,
                                    :discount_percentage, :invoice_date, :invoice_number,
                                    :notes, :po_number, :status, :sub_total, :tax_amount, :terms,
                                    :invoice_total, :archive_number, :archived_at, :deleted_at,
                                    :payment_terms_id, :due_date, :company_id,:currency_id, :project_id, :invoice_type,

    )
  end
end