#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
module Services
  #invoice related business logic will go here
  class InvoiceService
    include DateFormats
    # build a new invoice object
    def self.build_new_invoice(params)
      date_format = self.new.date_format
      if params[:invoice_for_client]
        company_id = get_company_id(params[:invoice_for_client])
        invoice = ::Invoice.new({:invoice_number => ::Invoice.get_next_invoice_number(nil), :invoice_date => Date.today.strftime(date_format), :client_id => params[:invoice_for_client], :payment_terms_id => (PaymentTerm.unscoped.present? && PaymentTerm.unscoped.first.id), :company_id => company_id})
        3.times { invoice.invoice_line_items.build() }
      elsif params[:id]
        invoice = ::Invoice.find(params[:id]).use_as_template
        invoice.invoice_line_items.build()
      else
        invoice = ::Invoice.new({:invoice_number => ::Invoice.get_next_invoice_number(nil), :invoice_date => Date.today.strftime(date_format), :payment_terms_id => (PaymentTerm.unscoped.present? && PaymentTerm.unscoped.first.id)})
        3.times { invoice.invoice_line_items.build() }
      end
      invoice.build_recurring_schedule
      invoice
    end

    def self.build_new_project_invoice(project)
      date_format = self.new.date_format
      project.invoices.new({:invoice_number => ::Invoice.get_next_invoice_number(nil), :invoice_date => Date.today.strftime(date_format), :payment_terms_id => (PaymentTerm.unscoped.present? && PaymentTerm.unscoped.first.id), client: project.client, currency: project.client.currency, invoice_type: "ProjectInvoice"})
    end

    # invoice bulk actions
    def self.perform_bulk_action(params)
      Services::InvoiceBulkActionsService.new(params).perform
    end

    def self.get_invoice_for_preview(encrypted_invoice_id)
      invoice_id = OSB::Util::decrypt(encrypted_invoice_id).to_i rescue invoice_id = nil
      invoice = ::Invoice.find_by_id(invoice_id)
      if invoice.blank?
        return ::Invoice.only_deleted.find_by_id(invoice_id).blank? ? nil : "invoice deleted"
      end
      invoice.viewed!
      invoice
    end

    def self.dispute_invoice(invoice_id, dispute_reason, current_user)
      invoice = ::Invoice.find_by_id(invoice_id)
      return nil if invoice.blank?
      invoice.disputed!
      InvoiceMailer.delay.dispute_invoice_email(current_user, invoice, dispute_reason)
      invoice = ::Invoice.find_by_id(invoice_id)
      invoice
    end

    def self.delete_invoices_with_payments(invoices_ids, convert_to_credit)
      ::Invoice.multiple(invoices_ids).each do |invoice|
        if convert_to_credit
          invoice.delete_credit_payments
          invoice.create_credit(invoice.non_credit_payment_total)
        end
        invoice.delete_none_credit_payments
        invoice.invoice_line_items.only_deleted.map(&:really_destroy!)
        invoice.destroy
      end
    end

    def self.paid_amount_on_update(invoice, params)
      invoice_amount = params[:invoice][:invoice_total].to_f
      paid_amount = invoice.payments.where("payment_type is null or payment_type != 'credit'").sum(:payment_amount).to_f

      # if invoice amount is less then paid amount then don't update invoice.
      response = if invoice.status == 'paid'
                   if invoice_amount < paid_amount
                     false
                   elsif invoice_amount > paid_amount
                     invoice.update_attributes(params[:invoice].permit!)
                     %w(draft draft-partial).include?(invoice.last_invoice_status) ? invoice.draft_partial! : invoice.partial!
                     true
                   else
                     invoice.update_attributes(params[:invoice].permit!)
                     true
                   end
                 elsif %w(partial draft-partial).include?(invoice.status)
                   if invoice_amount < paid_amount
                     false
                   elsif invoice_amount == paid_amount
                     invoice.update_attributes(params[:invoice].permit!)
                     invoice.update_attributes(last_invoice_status: invoice.status, status: 'paid')
                     true
                   else
                     invoice.update_attributes(params[:invoice].permit!)
                     true
                   end
                 end
      #Rails.logger.debug "\e[1;31m Response: #{response} \e[0m"
      response
    end

    def self.get_company_id(client_id)
      entities = ::Client.select('company_entities.parent_id').
          joins(:company_entities).
          where("company_entities.entity_id=? AND company_entities.entity_type = 'Client' AND company_entities.parent_type = 'Company'", client_id).
          group(:entity_id)
      entities.first.parent_id if entities.present?
    end


    def self.create_invoice_tasks(invoice)
      invoice.project.logs.each do |log|
        task = log.task
        invoice.invoice_tasks.create(name: task.name, description: task.description, rate: task.rate, hours: log.hours)
      end
    end

  end
end