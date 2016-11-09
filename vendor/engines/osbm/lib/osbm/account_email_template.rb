module Osbm
  class AccountEmailTemplate
    def self.generate(account_id)
      templates = EmailTemplate.create(
          [
              {
                  :torder => 1,
                  :status => 'Default',
                  :template_type => 'New Invoice',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{client_company}}: {{company_name}} Invoice: {{invoice_number}}',
                  :body => '<p>Dear {{client_contact}},</p>
            <p>Thank you for your continued service with {{company_name}}, to download a PDF copy for your records, click the link below:</p>
            <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a> </p>
            <p>Please remit payment at your earliest convenience. For all forms of payment please be sure to include your invoice number {{invoice_number}} for reference.</p>
            <p>If you have any questions or comments please feel free to contact {{company_contact}} at {{company_phone}}.</p>
            <p>Thanks,</p>
            <p>{{company_signature}}</p>'
              },
              {
                  :torder => 2,
                  :status => 'Default',
                  :template_type => 'Payment Received',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{company_name}} has received your payment for invoice {{invoice_number}}',
                  :body => '<p>We have received your payment in the amount of {{currency_symbol}}{{payment_amount}}  for invoice {{invoice_number}}.
                <p>To view the paid invoice or download a PDF copy for your records, click the link below:</p>
                <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a> </p>
                <p>Thank you. </p>
                <p>{{company_signature}}</p>'
              },
              {   :no_of_days => 2,
                  :is_late_payment_reminder => true,
                  :torder => 3,
                  :status => 'Default',
                  :template_type => 'First Late Payment Reminder',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{client_company}}: {{company_name}} Invoice is Past Due',
                  :body => '<p>Dear {{client_contact}},</p>
           <p>This is a friendly reminder that payment for your {{company_name}} invoice: {{invoice_number}} in the amount of {{currency_symbol}}{{payment_amount_due}} is past due.</p>
           <p>If there is a billing matter that you would like to discuss before submitting payment, please contact us as soon as possible at {{company_phone}}.</p>
           <p>To access your invoice go to: </p>
           <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a> </p>
           <p>Thank you.</p>
           <p>{{company_signature}}</p>'
              },
              {   :no_of_days => 5,
                  :is_late_payment_reminder => true,
                  :torder => 4,
                  :status => 'Default',
                  :template_type => 'Second Late Payment Reminder',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{client_company}}: {{company_name}} Invoice is Past Due',
                  :body => '<p>Dear {{client_contact}},</p>
           <p>This is a friendly reminder that payment for your {{company_name}} invoice: {{invoice_number}} in the amount of {{currency_symbol}}{{payment_amount_due}} is past due.</p>
           <p>If there is a billing matter that you would like to discuss before submitting payment, please contact us as soon as possible at {{company_phone}}.</p>
           <p>To access your invoice go to: </p>
           <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a> </p>
           <p>Thank you.</p>
           <p>{{company_signature}}</p>'
              },
              {   :no_of_days => 7,
                  :is_late_payment_reminder => true,
                  :torder => 5,
                  :status => 'Default',
                  :template_type => 'Third Late Payment Reminder',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{client_company}}: {{company_name}} Invoice is Past Due',
                  :body => '<p>Dear {{client_contact}},</p>
           <p>This is a friendly reminder that payment for your {{company_name}} invoice: {{invoice_number}} in the amount of {{currency_symbol}}{{payment_amount_due}} is past due.</p>
           <p>If there is a billing matter that you would like to discuss before submitting payment, please contact us as soon as possible at {{company_phone}}.</p>
           <p>To access your invoice go to: </p>
           <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a></p>
           <p>Thank you.</p>
           <p>{{company_signature}}</p>'
              },
              {
                  :torder => 6,
                  :status => 'Default',
                  :template_type => 'Dispute Invoice',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => 'Client Dispute Notification: {{client_company}}',
                  :body => '<p>{{company_contact}},</p>
           <p>{{client_company}} wishes to dispute {{company_name}} invoice {{invoice_number}}, citing:</p>
           <p>{{reason}}</p>
           <p>Please log into your account and respond accordingly.</p>
           <p>Thanks,</p>
           <p>Open Source Billing</p>'
              },
              {
                  :torder => 7,
                  :status => 'Default',
                  :template_type => 'Dispute Reply',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => '{{company_name}} Dispute Response regarding invoice {{invoice_number}}',
                  :body => '<p>Dear {{client_contact}},</p>
           <p>We have carefully reviewed your request regarding invoice number {{invoice_number}}. This is our response:</p>
           <p> {{dispute_response}}
           <p>URL for Invoice Preview:</p>
           <p><a href="{{invoice_url}}">Invoice# {{invoice_number}}</a></p>
           <p>Thank you.</p>
           <p>{{company_signature}}</p>'
              },
              {
                  :torder => 8,
                  :status => 'Default',
                  :template_type => 'New User',
                  :email_from => 'nfor20@yahoo.com',
                  :subject => 'Important {{company_name}} invoicing details courtesy of Open Source Billing',
                  :body => '<p>Welcome to {{company_name}}\'s secure online services provided by Open Source Billing.</p>
           <p>To securely access your account information and invoices, go to: </p>
           <p><a href="{{app_url}}">{{app_url}}</a></p>
           <p>Login using the following username and password:<p>
           <p> Username:  {{user_email}}
           <p>Password: {{user_password}}
           <p>If you have any questions please contact {{company_contact}} at {{company_phone}}.
           <p>Thank you.</p>
           <p>{{company_signature}}</p>'
              }
          ])

      templates.each do |template|
        CompanyEmailTemplate.create(
            :parent_id => account_id,
            :parent_type => 'Account',
            :template_id => template.id
        )
      end
    end
  end
end