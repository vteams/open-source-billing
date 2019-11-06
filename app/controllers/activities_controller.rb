class ActivitiesController < ApplicationController
  def index
  end

  def read_notifications
    PublicActivity::Activity.where.not(owner_id: current_user.id).update_all(is_read: true)
    render nothing: true
  end
end
