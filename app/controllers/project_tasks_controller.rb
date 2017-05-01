class ProjectTasksController < ApplicationController
  before_filter :find_project_task, only: [:show, :edit, :update, :destroy ]

  def new
    @project = Project.find(params[:project_id])
    @project_task = @project.project_tasks.build
  end

  def create
    @project = Project.find(params[:project_id])
    @project_task = @project.project_tasks.new(project_task_params)
    if @project_task.save
      redirect_to project_path(@project), notice: 'Task was successfully created.'
    else
      redirect_to project_path(@project), alert: 'Task was not successfully created.'
    end
  end

  def update
    if @project_task.update(project_task_params)
      redirect_to project_path(@project), notice: 'Task was successfully updated.'
    else
      redirect_to project_path(@project), alert: 'Task was not successfully updated.'
    end
  end
  
  def destroy
    @project_task.destroy
    redirect_to :back, notice: 'Project Task was successfully destroyed.'
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

