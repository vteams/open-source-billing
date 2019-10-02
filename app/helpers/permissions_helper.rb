module PermissionsHelper

  def setting_or_report? permission
    # @permission.where(entity_type: "Settings || Reports")
    permission.entity_type == "Settings" || permission.entity_type == "Report"
  end

  def setting_or_super_admin? permission, role
    permission.entity_type == "Settings" && role.user.id == current_user.id if role.user.present?
  end
end
