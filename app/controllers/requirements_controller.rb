class RequirementsController < ApplicationController
  include ActionView::Helpers::UrlHelper
  include RequirementsHelper

  layout "simple"

  before_filter :ensure_user_is_signed_in?
  before_filter :entry_accessed?

  def index
    @requirements = []

    if params[:project_id]
      @requirements = Requirement.where(project_id: params[:project_id], parent_id: 0)
    end
    render json: JSON::dump({ requirements: @requirements.map { |req| requirement_to_bootstrap_tree_item(req) if req.is_active }.compact})

  end

  def show
    if params[:id]
      @requirement = Requirement.find(params[:id])
      @requirement_attachments = @requirement.attachments.all
    end
  end

  def create
    @requirement = Requirement.create(params.require(:requirement).permit(:title, :description, :priority, :worth, :parent_id, :project_id, attachments_attributes: [:id, :requirement_id, :file]))

    if @requirement.save

      if params[:attachments]
        params[:attachments]['file'].each do |a|
          @requirement_attachment = @requirement.attachments.create!(:file => a)
        end
      end

      page_path = after_change_path(@requirement.id)
      render json: {page: page_path}
    else
      render json: {page: new_requirement_path}
    end
  end

  def new
    @requirement = Requirement.new(params.require(:requirement).permit(:project_id))
    authorize! :new, @requirement
    @requirement_attachment = @requirement.attachments.build
  end


  def edit
    @requirement = Requirement.find(params[:requirement])
    authorize! :update, @requirement
    @attachments = @requirement.attachments.all
    @requirement_attachment = Attachment.new
  end

  def update
    @requirement = Requirement.find(params[:id])
    if @requirement.update(params.require(:requirement).permit(:title, :description, :priority, :worth, attachments_attributes: [:id, :requirement_id, :file] ))
      page_path = after_change_path(@requirement.id)
      render json: {page: page_path}
    else
      render action: :edit
    end
  end

  def clear
    if params[:requirement_id]
      requirement = Requirement.find(params[:requirement_id])
      parent_id   = requirement.parent_id
      disable_requirements(requirement)

      if parent_id
        page_path = after_clear_path(parent_id)
        render json: {page: page_path}
      end
    end
  end

  def version_rollback
    if params[:requirement_id] && params[:version]

      page_path = after_change_path(params[:requirement_id])

      @requirement = Requirement.find(params[:requirement_id])

      if @requirement.revert_to!(params[:version].to_i)
        render json: {page: page_path}
      else
        render json: {page: new_requirement_path}
      end
    end
  end

  private

  def disable_requirements(requirement)
    requirement.self_and_descendents.each do |requirement|
      requirement.disable_requirement
    end
  end

  def after_clear_path(parent_id)
    if parent_id > 0
      requirement_path(parent_id)
    elsif parent_id == 0
      project_id = Requirement.find(params[:requirement_id]).project_id
      project_path(project_id)
    end    
  end

  def after_change_path(requirement_id)
    requirement_path(requirement_id)
  end

end