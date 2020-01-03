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
module ClientsHelper
  include ApplicationHelper


  def new_client id
    notice = <<-HTML
     <p>#{t('views.clients.created_msg')}</p>
    HTML
    notice.html_safe
  end

  def history_of_client
    activities_arr=[]
    @client.activities.each do |activity|
      unless activity.parameters.empty?
        if activity.key == "client.create"
          activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name} created client on #{activity.created_at.strftime("%d-%b-%y")}</div>")
        else
          activity.parameters['obj'].each do |p|
            previous_value = p[1][0]
            changed_value = p[1][1]
            unless p[0].include?('updated_at') || p[0].include?('created_at')
              if previous_value.present? && changed_value.present?
                activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name rescue ''} changed #{p[0]} to #{changed_value}</div>")
              elsif (previous_value.nil? || previous_value.empty?) && changed_value.present?
                activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name rescue ''} added #{p[0].humanize}  #{changed_value}</div>")
              elsif previous_value.present? && changed_value.empty?
                activities_arr << strip_tags("<div class='col-sm-12'>#{activity.owner.user_name rescue ''} removed #{p[0].humanize}  #{previous_value}</div>")
              end
            end
          end
        end
      end
    end
    activities_arr.reverse.join(", ").gsub(",", '<br/>').html_safe
  end


  def clients_archived ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.clients.bulk_archived_msg')}
    HTML
    notice.html_safe
  end

  def clients_deleted ids
    notice = <<-HTML
     <p>#{ids.size} #{t('views.clients.bulk_deleted_msg')}
    HTML
    notice.html_safe
  end

  def is_client_credit_payments client
    flag = false
    invoice_ids = Invoice.with_deleted.where("client_id = ?", client.id).all.pluck(:id)
    # total credit
    client_payments = Payment.where("payment_type = 'credit' AND invoice_id in (?)", invoice_ids).all
    client_total_credit = client_payments.sum(:payment_amount)
    flag = true if client_total_credit > 0
    flag
  end

  def unpaid_invoice_exists?(client_id)
    company = get_company_id
    company_filter = company.present? ? "invoices.company_id=#{company}" : ''
    for_client = "and client_id = #{client_id}"
    Invoice.joins(:client).where("(status != 'paid' or status is null) #{for_client}").where(company_filter).exists?
  end

  def unpaid_client_invoices_path(client_id)
    unpaid_invoice_exists?(client_id) ? invoices_unpaid_invoices_path(for_client: client_id) : 'javascript:void(0);'
  end

  def qb_customer_payment?(customer_ref)
    customer_ref.present? && customer_ref['value'].present?
  end

  def qb_client_email?(client_email)
    client_email.present? && client_email['Address'].present?
  end
end