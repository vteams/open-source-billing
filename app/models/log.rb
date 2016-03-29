class Log < ActiveRecord::Base

  belongs_to :project
  belongs_to :task, class_name: 'ProjectTask', foreign_key: :task_id

  validates :project_id,:task_id,:date , presence: true

end
