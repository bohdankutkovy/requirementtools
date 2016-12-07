# this controller is responsible for assigning users to different projects with different roles
class Admin::AssignmentsController < ApplicationController
  # it does provide various methods to handle assignment functionality
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
    columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|key,value| [value,key]} }

    # !!!
    # config.columns[:user].form_ui = :select
  end

  def update_config
    if current_user.is_super_admin
      acl_level = 0
    else
      assignment = current_user.assignments.where(project_id: params[:project_id]).first
      acl_level = assignment.acl_level if assignment
    end
    active_scaffold_config.columns[:acl_level].options = {options: Assignment::ACL_LEVELS.map{|key, value| [value, key] if key>acl_level}.compact }
  end

end