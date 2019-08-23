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
class SentEmailsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :set_per_page_session
  def index
    @sent_emails = SentEmail.page(params[:page]).per(@per_page).order(sort_column + " " + sort_direction)
    #filter emails by company
    @sent_emails = filter_by_company(@sent_emails)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def show
    @sent_email = SentEmail.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  private
  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    SentEmail.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def sent_email_params
    params.require(:sent_email).permit(:date, :recipient, :sender, :type, :subject, :content, :company_id, :notification_id, :notification_type)
  end

end
