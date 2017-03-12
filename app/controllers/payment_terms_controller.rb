class PaymentTermsController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  # GET /payment_terms
  # GET /payment_terms.json
  def index
    @payment_terms = PaymentTerm.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @payment_terms }
    end
  end

  # GET /payment_terms/1
  # GET /payment_terms/1.json
  def show
    @payment_term = PaymentTerm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @payment_term }
    end
  end

  # GET /payment_terms/new
  # GET /payment_terms/new.json
  def new
    @payment_term = PaymentTerm.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @payment_term }
    end
  end

  # GET /payment_terms/1/edit
  def edit
    @payment_term = PaymentTerm.find(params[:id])
  end

  # POST /payment_terms
  # POST /payment_terms.json
  def create
    @payment_term = PaymentTerm.new(payment_term_params)

    respond_to do |format|
      if @payment_term.save
        format.js #if params[:quick_create]
        format.json { render :json => @payment_term, :status => :created, :location => @payment_term }
      else
        format.html { render action: "new" }
        format.json { render json: @payment_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /payment_terms/1
  # PUT /payment_terms/1.json
  def update
    @payment_term = PaymentTerm.find(params[:id])

    respond_to do |format|
      if @payment_term.update_attributes(payment_term_params)
        format.html { redirect_to @payment_term, notice: 'Payment term was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @payment_term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_terms/1
  # DELETE /payment_terms/1.json
  def destroy
    @payment_term = PaymentTerm.find(params[:id])
    @payment_term.destroy

    respond_to do |format|
      format.html { redirect_to payment_terms_url }
      format.json { head :no_content }
    end
  end
  private

  def payment_term_params
    params.require(:payment_term).permit(:description, :number_of_days)
  end

end
