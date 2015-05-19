class EmailTemplate < ActiveRecord::Base
  paginates_per 10

  has_many :company_email_templates, :foreign_key => "template_id", :dependent => :destroy
  default_scope{order("#{self.table_name}.torder")}

  def self.get_email_templates(params)
    company_default_custom_templates(params)
  end

  def self.company_default_custom_templates(params)
    custom_templates = Company.find(params[:company_id]).email_templates
    default_templates = params[:user].current_account.email_templates

    # remove records from default, which have a custom templates
    custom_templates.each do |ct|
      default_templates.to_a.delete_if { |dt| dt["template_type"] == ct["template_type"] }
    end

    all_templates = default_templates + custom_templates
    all_templates.sort_by { |e| e[:torder] }
  end

  #delete the account level email template if a custom level company email template update as account level
  def delete_account_template
    company_id = CompanyEmailTemplate.where("template_id= ?", self.id).first.parent_id
    account_template = Company.find(company_id).account.email_templates.where("template_type = ?", self.template_type).first
    account_template.destroy
  end

  def self.late_payment_reminder_template(invoice, template_type)
    #find company level template of a template_type
    template = invoice.company.email_templates.where(:template_type => template_type).first

    #find account level template of template_type if no company level template
    template = Account.first.email_templates.where(:template_type => template_type).first if template.blank?
    template
  end
end
