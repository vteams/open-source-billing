class ProjectTask < ActiveRecord::Base

  belongs_to :task
  belongs_to :project
  has_one :log, dependent: :destroy, foreign_key: :task_id

  acts_as_archival

  def group_date
    updated_at.strftime('%B %Y')
  end

  def spent_time_percentage
    return 0 if hours.nil? or hours.zero?
    ((spent_time * 100)/hours).round
  end

end
