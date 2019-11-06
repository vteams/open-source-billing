class NotificationsController < ApplicationController
  def index
    @activities = PublicActivity::Activity.where.not(owner_id: current_user.id, key: 'client.update').order('created_at desc').page(params[:page].to_i + 1).per(10) if current_user.present?
    respond_to do |format|
      format.html { render :index, layout: false}
      format.js
    end
  end
end
