class AssignmentsController < ApplicationController
  include AssignmentsHelper

  layout "simple"

  before_filter :ensure_user_is_signed_in?
  before_filter :entry_accessed?

  def show
    if params[:id]
      @project     = Project.find(params[:id])
      @assignments = Assignment.where(project_id: params[:id])
    end
  end

  def create
    @assignment = Assignment.create(params.require(:assignment).permit(:project_id, :user_id, :acl_level))

    if @assignment.save
      page_path = after_change_path(@assignment.project_id)
      render json: {page: page_path}
    else
      render json: {page: new_assignment_path}
    end
  end

  def new
    @assignment = Assignment.new(params.require(:assignment).permit(:project_id))
    authorize! :new, @assignment
  end

  def edit
    @assignment = Assignment.find(params[:assignment])
    authorize! :update, @assignment
  end

  def update
    @assignment = Assignment.find(params[:id])

    if @assignment.update_attributes(params.require(:assignment).permit(:project_id, :user_id, :acl_level))
      page_path = after_change_path(@assignment.project_id)
      render json: {page: page_path}
    else
      render :action => "edit"
    end
  end

  def clear
    @assignment = Assignment.find(params[:assignment_id])
    authorize! :destroy, @assignment
    project_id = @assignment.project_id
    @assignment.destroy

    page_path = after_change_path(project_id)
    render json: {page: page_path}
  end

  def after_change_path(project_id)
    assignment_path(project_id)
  end
  
end