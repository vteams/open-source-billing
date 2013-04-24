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
class UserMailer < ActionMailer::Base
  default :from => "info@osb.com"

   def new_user_account(current_user, sub_user)
     @creator, @company, @sub_user = current_user.user_name || current_user.email , current_user.companies.first.org_name, sub_user
     Rails.logger.debug "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR #{@creator }"
     mail(:to => @sub_user.email, :subject => "Your Open Source Billing Account")
   end

end