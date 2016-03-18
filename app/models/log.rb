class Log < ActiveRecord::Base
  validates :project_id,:task_id,:date , presence: true

  belongs_to :project
  belongs_to :task

end
