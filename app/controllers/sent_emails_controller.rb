class SentEmailsController < ApplicationController
  load_and_authorize_resource :only => [:index, :show, :create, :destroy, :update, :new, :edit]
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
