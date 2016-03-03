class LogsController < ApplicationController
  def index
    @logs = Log.all
    @log = Log.new
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
      redirect_to @log, notice: 'Log was successfully created.'
    else
      render :new
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

  private

  def set_log
    @log = Log.find(params[:id])
  end

  def item_params
    params.require(:log).permit(:project_id, :task_id, :hours, :notes)
  end

end