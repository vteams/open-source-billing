class Log < ActiveRecord::Base

  belongs_to :project
  belongs_to :task, class_name: 'ProjectTask', foreign_key: :task_id
  belongs_to :user

  validates :project_id,:task_id,:date , presence: true

  before_create :set_user

  def line_total
    (hours * task.rate).round(2)
  end

  def set_user
    self.user = User.current
  end

end
