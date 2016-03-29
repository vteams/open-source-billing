class ProjectTask < ActiveRecord::Base

  belongs_to :task
  belongs_to :project
  has_many :logs, dependent: :destroy, foreign_key: :task_id

  acts_as_archival

end
