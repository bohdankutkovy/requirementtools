module Admin::AssignmentsHelper

  def status_column(record, field)
    Assignment::ACL_LEVELS[record.acl_level]
  end

  def user_column(record, field)
    link_to User.find_by_id(record.user_id).name, profile_path(record.user_id)
  end
end