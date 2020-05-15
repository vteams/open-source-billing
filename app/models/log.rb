class Log < ApplicationRecord

  belongs_to :project
  belongs_to :task, class_name: 'ProjectTask', foreign_key: :task_id
  belongs_to :user

  validates :project_id,:task_id,:date , presence: true

  before_create :set_user

  def line_total
    task.rate ? (hours * task.rate).round(2) : 0.0
  end

  def set_user
    self.user = User.current
  end

  def group_date
    date.strftime('%B %Y')
  end

  def image_name
    user.card_name.capitalize
  end

  def creator_name
    user.name
  end

  def task_name
    task.name
  end

end
