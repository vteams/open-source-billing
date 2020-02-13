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
  after_action :user_introduction, only: [:invoice_detail], unless: -> { current_user.introduction.report? }
  include Reporting

  def invoice_detail
    @report = Reporting::Reporter.get_report({:report_name => 'invoice_detail', :report_criteria => get_criteria(params)})
    authorize @report
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        render :pdf          => "#{@report.report_name}",
              :layout       => 'pdf_mode.html.erb',
              :template     => 'reports/invoice_detail.html.erb',
               footer:{
                   right: 'Page [page] of [topage]'
               },
              show_as_html: false
      end
    end
  end

  def item_sales
    @report = Reporting::Reporter.get_report({:report_name => 'item_sales', :report_criteria => get_criteria(params)})
    authorize @report

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        render  pdf: "#{@report.report_name}",
                layout: 'pdf_mode.html.erb',
                template: 'reports/item_sales.html.erb',
                encoding: "UTF-8",
                show_as_html: false,
                footer:{
                    right: 'Page [page] of [topage]'
                }

      end
    end
  end

  def revenue_by_client
    @report = Reporting::Reporter.get_report({:report_name => 'revenue_by_client', :report_criteria => get_criteria(params)})
    authorize @report

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        render pdf: "#{@report.report_name}",
               layout: 'pdf_mode.html.erb',
               template: 'reports/reports.html.erb',
               encoding: "UTF-8",
               show_as_html: false,
               footer:{
                   right: 'Page [page] of [topage]'
               }
      end
    end
  end

  def payments_collected
    @report = Reporting::Reporter.get_report({:report_name => 'payments_collected', :report_criteria => get_criteria(params)})
    authorize @report

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        render pdf: "#{@report.report_name}",
               layout: 'pdf_mode.html.erb',
               template: 'reports/payments_collected.html.erb',
               encoding: "UTF-8",
               show_as_html: false,
               footer:{
                   right: 'Page [page] of [topage]'
               }
      end
    end
  end

  def aged_accounts_receivable
    @report = Reporting::Reporter.get_report({:report_name => 'aged_accounts_receivable', :report_criteria => get_criteria(params)})
    authorize @report

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data @report.to_csv }
      format.xls { send_data @report.to_xls }
      format.xlsx { send_file(@report.to_xlsx.path, :filename => "#{params[:report_name]}.#{request.format.symbol}", :type => "#{request.format.to_s}", :disposition => "inline") }
      format.pdf do
        render pdf: "#{@report.report_name}",
               layout: 'pdf_mode.html.erb',
               template: 'reports/aged_accounts_receivable.html.erb',
               encoding: "UTF-8",
               show_as_html: false,
               footer:{
                   right: 'Page [page] of [topage]'
               }
      end
    end
  end


  private

  def get_criteria(options)
    if options[:criteria].present?
      options[:criteria].merge!(current_company: current_user.current_company.to_s, sort: params[:sort], direction: params[:direction])
    else
      options.merge!(criteria: {current_company: current_user.current_company.to_s, sort: params[:sort], direction: params[:direction]})
    end
    options
    @criteria = Reporting::Criteria.new(options[:criteria]) # report criteria
  end

  def get_report(options={})
  end

  def sort_column
    params[:sort] ||= 'clients.organization_name'
    sort_col = params[:sort]
    sort_col
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end