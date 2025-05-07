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
module OSB
  module Util
    def self.encrypt(value_to_encrypt)
      secret = Digest::SHA1.hexdigest(OSB::CONFIG::ENCRYPTION_KEY)
      e = ActiveSupport::MessageEncryptor.new(secret)
      Base64.encode64(e.encrypt_and_sign(value_to_encrypt))
    end

    def self.decrypt(value_to_decrypt)
      secret = Digest::SHA1.hexdigest(OSB::CONFIG::ENCRYPTION_KEY)
      e = ActiveSupport::MessageEncryptor.new(secret)
      e.decrypt_and_verify(Base64.decode64(value_to_decrypt))
    end

    def self.local_ip
      require "socket"
      orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true
      UDPSocket.open do |s|
        s.connect '64.233.187.99', 1
        s.addr.last
      end
    ensure
      Socket.do_not_reverse_lookup = orig
    end

    def self.filter(params)
      model = params[:controller].classify.constantize
      mappings = {active: 'unarchived', archived: 'archived', deleted: 'only_deleted'}

      model.send(mappings[params[:status].to_sym]).page(params[:page]).per(params[:per])
    end

  end
end