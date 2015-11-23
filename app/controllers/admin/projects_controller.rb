class Admin::ProjectsController < ApplicationController
  # before_filter :ensure_user_is_signed_in?
  before_filter :ensure_user_is_super_admin?
  before_filter :entry_accessed?

  active_scaffold :project do |config|
    config.list.columns   = [:title, :description, :my_status, :assignments ,:requirements]
    config.create.columns = [:title, :description]
    config.update.columns = [:title, :description]

    config.actions.exclude(:search)
  end

  def conditions_for_collection
    if current_user.is_super_admin?
      ['title = title']
    elsif current_user
      self.active_scaffold_outer_joins << :assignments
      self.active_scaffold_includes    << :assignments
      self.active_scaffold_references  << :assignments

      user_id = current_user.id

      ['assignments.user_id IN (?)', [ user_id.to_s]]
    end
  end



end
