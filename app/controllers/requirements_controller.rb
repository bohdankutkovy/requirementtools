# this controller is responsible for requirement functionality
class RequirementsController < ApplicationController
  include ActionView::Helpers::UrlHelper
  include RequirementsHelper

  layout "simple"

  before_filter :ensure_user_is_signed_in?
  before_filter :entry_accessed?

  def index
    @requirements = []

    project_id = params[:project_id]
    if project_id
      @requirements = Requirement.where(project_id: project_id, parent_id: 0)
    end
    render json: JSON::dump({ requirements: @requirements.map { |req| requirement_to_bootstrap_tree_item(req) if req.is_active }.compact})
  end

  def show
    requirement_id = params[:id]
    if requirement_id
      @requirement = Requirement.find(requirement_id)
      @requirement_attachments = @requirement.attachments.all
    end
  end

  def create
    @requirement = Requirement.create(params.require(:requirement).permit(:title, :description,  :priority, :worth, :parent_id, :project_id, attachments_attributes: [:id, :requirement_id, :file])
                                          .merge(author_id: current_user.id) )
    if @requirement.save
      attachments = params[:attachments]
      if attachments
        attachments['file'].each do |attachment|
          @requirement_attachment = @requirement.attachments.create!(:file => attachment)
        end
      end

      page_path = after_change_path(@requirement.id)
      render json: {page: page_path}
    end
  end

  def new
    @requirement = Requirement.new(params.require(:requirement).permit(:project_id), author_id: current_user.id)
    @requirement_attachment = @requirement.attachments.build
    authorize! :new, @requirement
  end


  def edit
    @requirement = Requirement.find(params[:requirement])
    @attachments = @requirement.attachments.all
    @requirement_attachment = Attachment.new
    authorize! :update, @requirement

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
    requirement_id = params[:requirement_id]
    if requirement_id
      requirement = Requirement.find(requirement_id)
      parent_id   = requirement.parent_id
      disable_requirements(requirement)

      if parent_id
        page_path = after_clear_path(parent_id)
        render json: {page: page_path}
      end
    end
  end

  def version_rollback
    requirement_id = params[:requirement_id]
    version = params[:version]
    if requirement_id && version

      page_path = after_change_path(requirement_id)

      @requirement = Requirement.find(requirement_id)

      if @requirement.revert_to!(version.to_i)
        render json: {page: page_path}
      end
    end
  end

  private

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