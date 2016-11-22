class Plan < ActiveRecord::Base
  has_many :users
  has_many :subscriptions

  def self.free_plan
    find_by(stripe_plan_id: 'free')
  end

  def is_free_plan?
    self == Plan.free_plan
  end
end
