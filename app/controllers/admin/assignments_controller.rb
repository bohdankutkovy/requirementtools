class Admin::AssignmentsController < ApplicationController
  include Admin::AssignmentsHelper

  before_filter :update_config
  before_filter :ensure_user_is_super_admin?
  before_filter :entry_accessed?

  active_scaffold :assignment do |config|
    config.list.columns   = [:user, :project, :status]
    config.create.columns = [:user, :project, :acl_level]
    config.update.columns = [:user, :project, :acl_level]

    config.actions.exclude(:search)
    columns[:user].form_ui      = :select
    columns[:project].form_ui   = :select
    columns[:acl_level].form_ui = :select
    columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v,k]} }

    # !!!
    # config.columns[:user].form_ui = :select
  end

  def update_config
    if current_user.is_super_admin
      active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v, k] } }
    else
        if current_user.assignments.where(project_id: params[:project_id]).first
        case current_user.assignments.where(project_id: params[:project_id]).first.acl_level
          when 0
            active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v, k] if k>=0}.compact }
          when 1
            active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v, k] if k>1}.compact }
          when 2
            active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v, k] if k>2}.compact }
          when 3
            active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|k,v| [v, k] if k>3}.compact }
        end
      end
    end
  end

end