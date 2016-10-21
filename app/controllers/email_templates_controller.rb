class EmailTemplatesController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
  # GET /email_templates
  # GET /email_templates.json
  helper_method :sort_column, :sort_direction

  def index
    #@email_templates = EmailTemplate.page(params[:page]).per(params[:per])
    params[:company_id] = get_company_id if params[:company_id].blank?
    @email_templates = EmailTemplate.get_email_templates(params.merge(user: current_user))#.page(params[:page]).per(params[:per])
    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @email_templates }
    end
  end

  # GET /email_templates/1
  # GET /email_templates/1.json
  def show
    @email_template = EmailTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @email_template }
    end
  end

  # GET /email_templates/new
  # GET /email_templates/new.json
  def new
    @email_template = new_custom_email_template
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @email_template }
    end
  end

  # GET /email_templates/1/edit
  def edit
    @email_template = EmailTemplate.find(params[:id])
  end

  # POST /email_templates
  # POST /email_templates.json
  def create
    @email_template = EmailTemplate.new(email_template_params)
    @email_template.status = "Custom"
    associate_entity(params,@email_template)
    respond_to do |format|
      if @email_template.save
        format.html { redirect_to @email_template, notice: 'Email template was successfully created.' }
        format.json { render json: @email_template, status: :created, location: @email_template }
        redirect_to({:action => "edit", :controller => "email_templates", :id => @email_template.id}, :notice => 'Your Email Template has been updated successfully.')
        return
      else
        format.html { render action: "new" }
        format.json { render json: @email_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /email_templates/1
  # PUT /email_templates/1.json
  def update
    @email_template = EmailTemplate.find(params[:id])
    company_template = CompanyEmailTemplate.where("template_id = ? and parent_type = 'Company'",params[:id]).present?

    if company_template   #Only do it if editing a custom email template
     @email_template.delete_account_template if params[:association] == "account"
    elsif params[:association] == "company"
     @email_template =  EmailTemplate.new(email_template_params)
    end

    @email_template.status = params[:association] == "company" ? "Custom" : "Default"
    associate_entity(params,@email_template)

    respond_to do |format|
      if @email_template.update_attributes(email_template_params) or @email_template.save
        format.html { redirect_to @email_template, notice: 'Email template was successfully updated.' }
        format.json { head :no_content }
        redirect_to({:action => "edit", :controller => "email_templates", :id => @email_template.id}, :notice => 'Your Email Template has been updated successfully.')
        return
      else
        format.html { render action: "edit" }
        format.json { render json: @email_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_templates/1
  # DELETE /email_templates/1.json
  def destroy
    @email_template = EmailTemplate.find(params[:id])
    @email_template.destroy

    respond_to do |format|
      format.html { redirect_to email_templates_url }
      format.json { head :no_content }
    end
  end

  # Load email template data
  def load_email_template
    template = EmailTemplate.find(params[:id])
    render :text => [template.email_from|| "", template.subject || "", template.body || ""]
  end

  def new_custom_email_template(template_id = nil)
    t = EmailTemplate.find(template_id)
    template_params = {}
    template_params = {torder: t.torder, template_type: t.template_type, subject: t.subject, email_from: t.email_from, body: t.body} if t
    EmailTemplate.new(template_params)
  end

  def sort_column
    params[:sort] ||= 'created_at'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def email_template_params
    params.require(:email_template).permit(:body, :email_from, :subject, :template_type, :status, :torder, :no_of_days, :is_late_payment_reminder, :send_email)
  end

end
