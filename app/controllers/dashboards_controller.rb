class DashboardsController < ApplicationController
  respond_to :js, :json, :html
  
  before_filter :entry_accessed?, only: :index

  def index
    @user = current_user
    if current_user.is_super_admin
      @projects = Project.all
    else
      @projects = current_user.assignments.map{ |assignment| assignment.project }
    end
  end

end
