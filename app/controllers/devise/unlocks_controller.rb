#
# Open Source Billing - A super simple software to create & send invoices to your customers and
# collect payments.
# Copyright (C) 2013 Mark Mian <mark.mian@opensourcebilling.org>
#
# This file is part of Open Source Billing.
#
# Open Source Billing is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Open Source Billing is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Open Source Billing.  If not, see <http://www.gnu.org/licenses/>.
#
class Devise::UnlocksController < DeviseController
  prepend_before_filter :require_no_authentication

  # GET /resource/unlock/new
  def new
    build_resource({})
  end

  # POST /resource/unlock
  def create
    self.resource = resource_class.send_unlock_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_unlock_instructions_path_for(resource))
    else
      respond_with(resource)
    end
  end

  # GET /resource/unlock?unlock_token=abcdef
  def show
    self.resource = resource_class.unlock_access_by_token(params[:unlock_token])

    if resource.errors.empty?
      set_flash_message :notice, :unlocked if is_navigational_format?
      respond_with_navigational(resource) { redirect_to after_unlock_path_for(resource) }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity) { render :new }
    end
  end

  protected

  # The path used after sending unlock password instructions
  def after_sending_unlock_instructions_path_for(resource)
    new_session_path(resource)
  end

  # The path used after unlocking the resource
  def after_unlock_path_for(resource)
    new_session_path(resource)
  end

end