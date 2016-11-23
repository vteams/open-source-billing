class ProjectTask < ActiveRecord::Base

  include Osbm
  belongs_to :task
  belongs_to :project
  has_one :log, dependent: :destroy, foreign_key: :task_id

  acts_as_archival

end
