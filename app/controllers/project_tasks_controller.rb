class ProjectTasksController < ApplicationController
  before_filter :find_project_task, only: [:show, :edit, :update, :destroy ]

  def new
    @project = Project.find(params[:project_id])
    @project_task = @project.project_tasks.build
  end

  def create
    @project = Project.find(params[:project_id])
    params[:project_task][:spent_time] = 0.0 if params[:project_task][:spent_time].to_f <= 0.0
    @project_task = @project.project_tasks.new(project_task_params)
    if @project_task.save
      @project_task.create_time_log(current_user)
      redirect_to project_path(@project), notice: 'Task was successfully created.'
    else
      redirect_to project_path(@project), alert: 'Task was not successfully created.'
    end
  end

  def update
    params[:project_task][:spent_time] = 0.0 if params[:project_task][:spent_time].to_f <= 0.0
    if @project_task.update(project_task_params)
      @project_task.update_time_log(current_user)
      redirect_to project_path(@project), notice: 'Task was successfully updated.'
    else
      redirect_to project_path(@project), alert: 'Task was not successfully updated.'
    end
  end
  
  def destroy
    @project_task.destroy

    respond_to do |format|
      format.html { redirect_to project_path(@project.id) }
      format.json { head :no_content }
    end
  end

  private

    def find_project_task
      @project = Project.find(params[:project_id])
      @project_task = @project.project_tasks.where(id: params[:id]).first
    end

    def project_task_params
      params.require(:project_task).permit(:name, :description, :start_date, :due_date, :hours, :spent_time, :rate, :project_id)
    end
end

