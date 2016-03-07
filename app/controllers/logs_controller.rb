class LogsController < ApplicationController
  before_action :set_log, only: [:show, :edit, :update, :destroy]
  layout 'application'
  protect_from_forgery

  def index
    @date = params[:date] || Time.zone.now.beginning_of_day
    @logs = Log.where('date = ?', @date)
    @log = Log.new
    @tasks = [] # Project.find(true)
    respond_to do |format|
      format.html # index.html.erb
      format.js
    end

  end

  def new
    @log = Log.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @log = Log.new(log_params)

    if @log.save
      #redirect_to @log, notice: 'Log was successfully created.'
      @logs = Log.where('created_at >= ?', Time.zone.now.beginning_of_day)
      respond_to do |format|
        format.html # index.html.erb
        format.js
      end
    else
      render :index
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @log.update(log_params)
      redirect_to @log, notice: 'Log was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /tasks/1
  def destroy
    @log.destroy
    redirect_to logs_url, notice: 'Log was successfully destroyed.'
  end

  def events
    @logs = Log.all.group(:date).sum(:hours)

    respond_to do |format|
      format.json
    end
  end

  def update_tasks
    #binding.pry
    project_id = params[:project_id].to_i
    unless project_id == 0
      @tasks = Project.find(project_id).project_tasks
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def set_log
    @log = Log.find(params[:id])
  end

  def log_params
    params.require(:log).permit(:project_id, :task_id, :hours, :notes, :date)
  end

end