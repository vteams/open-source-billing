class MailConfig < ActiveRecord::Base
  belongs_to :company

  AUTHENTICATION_TYPES = %w(plain login cram_md5)
  OPEN_SSL_VERIFICATIONS_MODES = %w(peer none)

end
