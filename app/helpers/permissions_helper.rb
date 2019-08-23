module PermissionsHelper

  def setting_or_report? permission
    # @permission.where(entity_type: "Settings || Reports")
    permission.entity_type == "Settings" || permission.entity_type == "Report"
  end
end
