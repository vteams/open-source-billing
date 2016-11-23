class InvoiceTask < ActiveRecord::Base
  include Osbm
  belongs_to :invoice

end
