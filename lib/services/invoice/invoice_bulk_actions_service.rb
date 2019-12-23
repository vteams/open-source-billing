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
  class InvoiceBulkActionsService
    attr_reader :invoices, :invoice_ids, :options, :action_to_perform

    def initialize(options)
      actions_list = %w(archive destroy recover_archived recover_deleted send payment destroy_archived)
      @options = options
      @action_to_perform = actions_list.map { |action| action if @options[action] }.compact.first #@options[:commit]
      @invoice_ids = @options[:invoice_ids]
      @invoices = ::Invoice.multiple(@invoice_ids)
      @current_user = @options[:current_user]
    end

    def perform
      method(@action_to_perform == 'send' ? 'send_invoices' : @action_to_perform).call.merge({invoice_ids: @invoice_ids, action_to_perform: @action_to_perform})
    end

    def archive
      @invoices.map(&:archive)
      {action: 'archived', invoices: get_invoices('unarchived')}
    end

    def destroy
      # invoices_with_payments = @invoices.select { |invoice| invoice.has_payment? }
      # invoices_for_delete = @invoices - invoices_with_payments
      invoices_for_delete = @invoices
      invoices_with_payments = nil
      invoices_for_delete.each do |invoice|
        invoice.invoice_line_items.only_deleted.map(&:really_destroy!)
      end

      (invoices_for_delete).map(&:destroy)

      action = invoices_with_payments.present? ? 'invoices_with_payments' : 'deleted'
      {action: action, invoices_with_payments: invoices_with_payments, invoices: get_invoices('unarchived')}
    end

    def destroy_archived
      # invoices_with_payments = @invoices.select { |invoice| invoice.has_payment? }
      # invoices_for_delete = @invoices - invoices_with_payments
      invoices_for_delete = @invoices
      invoices_with_payments = nil
      invoices_for_delete.each do |invoice|
        invoice.invoice_line_items.only_deleted.map(&:really_destroy!)
      end

      (invoices_for_delete).map(&:destroy)

      action = invoices_with_payments.present? ? 'invoices_with_payments' : 'deleted from archived'
      {action: action, invoices_with_payments: invoices_with_payments, invoices: get_invoices('archived')}
    end

    def recover_archived
      @invoices.map(&:unarchive)
      {action: 'recovered from archived', invoices: get_invoices('archived')}
    end

    def recover_deleted
      @invoices.only_deleted.map { |invoice| invoice.restore; invoice.unarchive; invoice.change_status_after_recover; invoice.invoice_line_items.only_deleted.map(&:restore); }
      invoices = ::Invoice.only_deleted.page(@options[:page]).per(@options[:per])
      {action: 'recovered from deleted', invoices: get_invoices('only_deleted')}
    end

    def send_invoices
      @invoices.map { |invoice| invoice.update_attribute(:status, 'sent') if (send_invoice_to_client(invoice) and (invoice.status != 'paid' and invoice.status != 'partial')) }
      {action: 'sent', invoices: get_invoices('unarchived')}
    end

    def payment
      action = @invoices.where(status: 'paid').present? ? 'paid invoices' : 'enter payment'
      {action: action, invoices: @invoices}
    end

    private

    def send_invoice_to_client(invoice)
      # invoice_hash = {
      #     invoice_client: invoice.clients,
      #     invoice: invoice,
      #     encrypted_id: invoice.encrypted_id,
      #     user: @current_user
      # }
      # NotificationWorker.perform_async('InvoiceMailer','new_invoice_email',[invoice_hash], smtp_settings = Company.smtp_settings)
      InvoiceMailer.delay.new_invoice_email(invoice.client, invoice, invoice.encrypted_id, @current_user)
    end

    private

    def get_invoices(invoice_filter)
      ::Invoice.joins("LEFT OUTER JOIN clients ON clients.id = invoices.client_id ").send(invoice_filter).page(@options[:page]).per(@options[:per])
    end
  end
end
