module SubUsersHelper
  def load_user_roles
    Role.all.map{|r| [r.name.humanize, r.id]}
  end
end
