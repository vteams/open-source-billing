class ActivitiesController < ApplicationController
  def index
  end

  def read_notifications
      @activities.update_all(is_read: true)
    render nothing: true
  end
end
