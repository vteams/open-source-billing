module SubUsersHelper
  def load_user_roles
    Role.all.map{|r| [r.name.humanize, r.id]}
  end

  def load_companies
    Company.all.map{|c| [c.name.humanize, c.id]}
  end

  def password_has_changed?(user_id, password)
    current_user.id.to_s.eql?("#{user_id}") && password.present?
  end
end
