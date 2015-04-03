class SettingsController < ApplicationController
  def create
      user = current_user
    if params[:currency_select].present?
      user.settings.currency = "On"
      respond_to { |format| format.js }
    else
      user.settings.currency = "Off"
      respond_to { |format| format.js }
    end
  end
end
