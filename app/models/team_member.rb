class TeamMember < ActiveRecord::Base
  include Osbm
  belongs_to :staff
  belongs_to :project

  acts_as_archival
end
