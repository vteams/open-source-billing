class Role < ActiveRecord::Base
  #include Osbm
  has_and_belongs_to_many :users, :join_table => :users_roles
  has_many :permissions

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
