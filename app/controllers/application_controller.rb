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
class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :_reload_libs #reload libs on every request for dev environment only
                              #layout :choose_layout
                              #reload libs on every request for dev environment only
  def _reload_libs
    if defined? RELOAD_LIBS
      RELOAD_LIBS.each do |lib|
        #require_dependency lib
      end
    end
  end

  def after_sign_in_path_for(user)
    dashboard_path
  end

  def after_sign_out_path_for(user)
    #categories_path
    dashboard_path
  end

  def encryptor
    secret = Digest::SHA1.hexdigest("yourpass")
    ActiveSupport::MessageEncryptor.new(secret)
  end

  def encrypt(message)
    e = encryptor
    e.encrypt(message)
  end

  def decrypt(message)
    e = encryptor
    e.decrypt(message)
  end

  def choose_layout
    %w(preview payments_history).include?(action_name) ? 'preview_mode' : 'application'
  end

end