module AssignmentsHelper


  def link_to_user_for(assignment)
    link_to( User.find(assignment.user_id).name, profile_path(assignment.user_id) , :target => '_blank')
  end



  def status_of_user_for(assignment)
    Assignment::ACL_LEVELS[assignment.acl_level]
  end

  def project_acl_levels_for_select(project_id)
    acl_levels = Assignment::ACL_LEVELS.dup

    if !current_user.is_super_admin?
      current_user_acl = current_user.assignments.where(:project_id => project_id).first.acl_level
      acl_levels.select!{ |k, v| current_user_acl == 0 ? k >= current_user_acl : k > current_user_acl }
    end

    acl_levels.map{ |k,v| [v, k] }
  end

end

