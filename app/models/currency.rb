class Currency < ActiveRecord::Base
  #attr_accessible :code, :title, :unit
  validates :code,:title,:unit , presence: true
end
