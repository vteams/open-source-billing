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
class ReportsController < ApplicationController
  helper_method :sort_column, :sort_direction
  include Reporting

  def index

  end


  # first time report load
  # reports/:report_name
  def reports
    Rails.logger.debug "--> in reports_controller#report... #{params.inspect} "
    criteria = get_criteria(params)
    @report = get_report(criteria)
    respond_to do |format|
      format.html # index.html.erb
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        file_name = "#{@report.report_name}_#{Date.today}.pdf"
        pdf = render_to_string  pdf: "#{@report.report_name}",
          layout: 'pdf_mode.html.erb',
          template: 'reports/reports.html.erb',
          encoding: "UTF-8",
          footer:{
            right: 'Page [page] of [topage]'
          }
        send_data pdf,filename: file_name
      end
    end
  end

  # AJAX request to fetch report data after
  # reports/data/:report_name
  def reports_data
    criteria = get_criteria(params)
    @report = get_report(criteria)

    respond_to do |format|
      format.js
    end
  end

  private

  def get_criteria(options)
    if options[:criteria].present?
      options[:criteria].merge!(current_company: current_user.current_company.to_s)
    else
      options.merge!(criteria: {current_company: current_user.current_company.to_s})
    end
    options
  end

  def get_report(options={})
    @criteria = Reporting::Criteria.new(options[:criteria]) # report criteria
    Reporting::Reporter.get_report({:report_name => options[:report_name], :report_criteria => @criteria})
  end

  def sort_column
    params[:sort] ||= 'created_at'
    sort_col = params[:sort]
    sort_col
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end