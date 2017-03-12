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
