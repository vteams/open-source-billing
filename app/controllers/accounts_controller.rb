class AccountsController < ApplicationController
  # GET /companies
  # GET /companies.json
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  def index
    @accounts = current_user.accounts

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accounts }
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @account = Account.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @account }
    end
  end

  # GET /companies/new
  # GET /companies/new.json
  def new
    user_company = current_user.accounts
    if user_company.present?
      @account = user_company.first
      redirect_to edit_account_url(@account)
    else
      @account = user_company.build
      respond_to { |format| format.html }
    end
  end

  # GET /companies/1/edit
  def edit
    @account = Account.find(params[:id])
  end

  # POST /companies
  # POST /companies.json
  def create
    @account = current_user.accounts.build(account_params)

    respond_to do |format|
      if current_user.save
        format.html { redirect_to edit_account_url(@account), notice: 'Account was successfully created.' }
        format.json { render json: @account, status: :created, location: @account }
      else
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end

    end
  end

  # PUT /companies/1
  # PUT /companies/1.json
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(account_params)
        format.html { redirect_to edit_account_url(@account), notice: 'Your account has been updated successfully.'}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @account = Account.find(params[:id])
    current_user.accounts.destroy(@account)

    respond_to do |format|
      format.html { redirect_to companies_url }
      format.json { head :no_content }
    end
  end
  private

  def account_params
    params.require(:account).permit(:admin_billing_rate_per_hour, :admin_email, :admin_first_name, :admin_last_name, :admin_password, :admin_user_name, :auto_dst_adjustment, :city, :country, :currency_symbol, :currency_code, :email, :fax, :org_name, :phone_business, :phone_mobile, :postal_or_zip_code, :profession, :province_or_state, :street_address_1, :street_address_2, :time_zone)
  end

end
