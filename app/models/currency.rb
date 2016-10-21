class Currency < ActiveRecord::Base
  validates :code,:title,:unit , presence: true

  def self.default_currency
    currency = Currency.where(unit: current_user_default_currency_code(current_user)).first || Currency.first
    currency
  end

  def self.current_user
    User.current
  end

  def self.current_user_default_currency_code(user)
    user.settings.default_currency
  end

end
