class SettingsController < ApplicationController
  def create
    user = current_user
    @language_changed = false
    if params[:currency_select].present?
      user.settings.currency = "On"
    else
      user.settings.currency = "Off"
    end
    if params[:date_format].present?
      user.settings.date_format = params[:date_format]
    end
    if params[:records_per_page].present?
      user.settings.records_per_page = params[:records_per_page]
    end
    if params[:locale].present?
      user.settings.language = params[:locale]
      @language_changed = true
    end
    if params[:default_currency].present?
      user.settings.default_currency = params[:default_currency]
    end
    respond_to { |format| format.js }
  end
end
