class Admin::RequirementsController < ApplicationController
  before_filter :ensure_user_is_super_admin?
  before_filter :entry_accessed?

  active_scaffold :requirement do |config|
    config.list.columns     = [:title, :description, :priority, :worth, :children, :project, :attachments, :author_id, :is_active]
    config.create.columns   = [:title, :description, :priority, :worth]
    config.update.columns   = [:title, :description, :priority, :worth, :is_active]
    config.create.multipart = true
    config.update.multipart = true

    config.actions.exclude(:search)

    config.columns[:project].form_ui = :select
  end

  private

  def conditions_for_collection
    if !nested? || params[:parent_scaffold]=='admin/projects'
      ['parent_id = 0']
    end
  end


end
