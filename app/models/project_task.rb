class ProjectTask < ActiveRecord::Base

  belongs_to :task
  belongs_to :project

  acts_as_archival

end
