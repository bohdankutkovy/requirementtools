class ProjectsController < ApplicationController
  before_filter :ensure_user_is_signed_in?
  before_filter :entry_accessed?, only: :index
  layout "simple"

  def show
    if params[:id]
      if !Project.where(id: params[:id]).empty?
        @project = Project.where(id: params[:id]).first
      else
        render nothing: true, status: 200, content_type: 'text/html'
      end
    end
  end

end