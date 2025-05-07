class ProjectTask < ActiveRecord::Base

  belongs_to :task
  belongs_to :project
  has_one :log, dependent: :destroy, foreign_key: :task_id

  acts_as_archival

  def group_date(format = '%B %Y')
    updated_at.strftime(format)
  end

  def spent_time_percentage
    return 0 if hours.nil? or hours.zero?
    ((spent_time * 100)/hours).round
  end

  def create_time_log(user)
    build_log(project_id: project_id, hours: spent_time, user_id: user.id, date: updated_at.to_date).save
  end

  def update_time_log(user)
    log.present? ? log.update(hours: spent_time, user_id: user.id, date: updated_at.to_date) : create_time_log(user)
  end

end
