class MailConfig < ActiveRecord::Base
  belongs_to :company

  AUTHENTICATION_TYPES = %w(plain login cram_md5)

end
