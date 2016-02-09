class EstimatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_per_page_session
  protect_from_forgery
  helper_method :sort_column, :sort_direction
  include DateFormats

  layout :choose_layout
  include InvoicesHelper

  def index
    params[:status] = params[:status] || 'active'
    @estimates = Estimate.joins("LEFT OUTER JOIN clients ON clients.id = estimates.client_id ").filter(params,@per_page).order("#{sort_column} #{sort_direction}")
    @estimates = filter_by_company(@estimates)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end
  end

  def new

  end

  def set_per_page_session
    session["#{controller_name}-per_page"] = params[:per] || session["#{controller_name}-per_page"] || 10
  end

  def sort_column
    params[:sort] ||= 'created_at'
    Estimate.column_names.include?(params[:sort]) ? params[:sort] : 'clients.organization_name'
  end

  def sort_direction
    params[:direction] ||= 'desc'
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end