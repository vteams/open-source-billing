class LineItemTax < ApplicationRecord

  belongs_to :invoice_line_item
  acts_as_archival
  acts_as_paranoid
end
