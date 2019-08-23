class ExpensesController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :set_per_page_session
  before_action :set_expense, only: [:show, :edit, :update, :destroy]
  include ExpensesHelper

  # GET /expenses
  def index
    params[:status] ||= 'active'
    @status = params[:status]
    @expenses = Expense.joins(:client, :category).filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @expenses = filter_by_company(@expenses)
    @expense_activity = Reporting::ExpenseActivity.get_recent_activity(get_company_id, @per_page, params)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: expenses }
      format.js
    end
  end

  # GET /expenses/1
  def show
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: expenses }
      format.js
    end
  end

  # GET /expenses/new
  def new
    @expense = Expense.new
    @expense.company_id = get_company_id()
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /expenses/1/edit
  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /expenses
  def create
    @expense = Expense.new(expense_params)
    @expense.company_id = get_company_id()
    if @expense.save
      redirect_to expenses_path, notice: 'Expense was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /expenses/1
  def update
    if @expense.update(expense_params)
      redirect_to expenses_path, notice: 'Expense was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /expenses/1
  def destroy
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to expenses_url }
      format.json { head :no_content }
    end
  end

  def filter_expenses
    @companies = Expense.filter(params.merge(per: session["#{controller_name}-per_page"])).order(sort_column + " " + sort_direction)
    respond_to { |format| format.js }
  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end
  
  def bulk_actions
      params[:sort] = params[:sort] || 'created_at'
      result = Services::ExpenseBulkActionsService.new(params.merge({current_user: current_user})).perform
      @expenses = result[:expenses]
      @message = get_intimation_message(result[:action_to_perform], result[:expense_ids])
      @action = result[:action]
    #end
      respond_to do |format|
        format.html { redirect_to expenses_url, notice: "Expense(s) are #{@action} successfully." }
        format.js
      end
  end

  def undo_actions
    params[:archived] ? Expense.recover_archived(params[:ids]) : Expense.recover_deleted(params[:ids])
    @expenses = Expense.unarchived.page(params[:page]).per(session["#{controller_name}-per_page"])
    respond_to { |format| format.js }
  end

  private
    def get_intimation_message(action_key, expense_ids)
      helper_methods = {archive: 'expenses_archived', destroy: 'expenses_deleted'}
      helper_method = helper_methods[action_key.to_sym]
      helper_method.present? ? send(helper_method, expense_ids) : nil
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_expense
      @expense = Expense.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def expense_params
      params.require(:expense).permit(:amount, :expense_date, :category_id, :note, :client_id, :tax_1, :tax_2)
    end

  def sort_column
    params[:sort].present? ? params[:sort] : 'created_at'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
