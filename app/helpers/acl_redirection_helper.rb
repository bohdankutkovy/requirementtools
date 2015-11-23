module AclRedirectionHelper

  def ensure_user_is_super_admin?
    if current_user.nil? || (current_user.info_edited  && !current_user.is_super_admin? && !current_user.assignments.where(:project_id => params[:project_id]))
        raise CanCan::AccessDenied
    end
  end

  def entry_accessed?
    if current_user.nil? || (!current_user.info_edited  && !current_user.is_super_admin?)
      raise CanCan::AccessDenied
    end
  end


  def ensure_user_is_signed_in?
    if current_user.nil?
      raise CanCan::AccessDenied
    end
  end




end