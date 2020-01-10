class Currency < ActiveRecord::Base
  validates :code,:title,:unit , presence: true

  scope :with_invoices, -> { joins("LEFT OUTER JOIN invoices ON invoices.currency_id = currencies.id ")}
  scope :having_invoices, -> { joins("RIGHT OUTER JOIN invoices ON invoices.currency_id = currencies.id ")}

  has_many :invoices

  def self.default_currency
    currency = Currency.find_by(unit: Settings.default_currency) || Currency.first
    currency
  end

  def self.current_user
    User.current
  end

  def self.current_user_default_currency_code(user)
    user.settings.default_currency rescue Currency.first
  end

end
