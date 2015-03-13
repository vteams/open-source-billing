class Currency < ActiveRecord::Base
  validates :code,:title,:unit , presence: true

  def self.default_currency
    currency = Currency.where(unit: 'USD').first || Currency.first
    currency
  end
end
