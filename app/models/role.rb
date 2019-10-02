class Role < ActiveRecord::Base
  #include Osbm
  has_one :user
  has_many :permissions, dependent: :destroy

  belongs_to :resource,
             :polymorphic => true

  accepts_nested_attributes_for :permissions,  :allow_destroy => true


  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  validates :name, presence:  {message: "cannot be blank"}
  validates :name, uniqueness: {message: "should be unique"}

  scopify

  def role_name
    name.first.camelize
  end

end
