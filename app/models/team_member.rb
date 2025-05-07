class TeamMember < ActiveRecord::Base
  belongs_to :staff
  belongs_to :project

  acts_as_archival
end
