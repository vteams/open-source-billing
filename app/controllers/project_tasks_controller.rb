class ProjectTasksController < ApplicationController
  before_filter :find_project_task, only: [:show, :edit, :destroy ]

  def destroy
    @project_task.destroy
    redirect_to :back, notice: 'Project Task was successfully destroyed.'
  end

  private

    def find_project_task
      @project = Project.find(params[:project_id])
      @project_task = @project.project_tasks.where(id: params[:id]).first
    end

end

