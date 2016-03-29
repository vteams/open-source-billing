class Log < ActiveRecord::Base

  belongs_to :project
  belongs_to :task

  validates :project_id,:task_id,:date , presence: true

end
