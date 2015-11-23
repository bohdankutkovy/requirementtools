module Admin::ProjectsHelper

  def my_status_column(record, field)
    if current_user.is_super_admin
      Assignment::ACL_LEVELS[0]
    elsif current_user.assignments.where(:project_id => record.id).first
      acl_level = current_user.assignments.where(:project_id => record.id).first.acl_level
      Assignment::ACL_LEVELS[acl_level]
    end
  end

end
