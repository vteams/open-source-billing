class EmailTemplatesController < ApplicationController


  # GET /email_templates/1/edit
  def edit
    @email_template = EmailTemplate.find(params[:id])
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
        format.html { redirect_to settings_path, notice: t('views.email_templates.updated_msg') }
        format.json { head :no_content }
        redirect_to settings_path, notice: t('views.email_templates.updated_msg')
        return
      else
        format.html { render action: "edit" }
        format.json { render json: @email_template.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def email_template_params
    params.require(:email_template).permit(:body, :email_from, :subject, :template_type, :status, :torder, :no_of_days, :is_late_payment_reminder, :send_email, :cc, :bcc)
  end

end
