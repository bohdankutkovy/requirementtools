class AttachmentsController < ApplicationController

  def clear
    @attachment = Attachment.find(params[:attachment_id])

    @attachment.destroy

    page_path = after_change_path(@attachment.requirement_id)
    render json: {page: page_path}
  end

  def create
    params[:attachment][:file].each do |file|
      Attachment.create!(
          requirement_id: params[:attachment][:requirement_id],
          file: file
      )
    end

    page_path = after_change_path(params[:attachment][:requirement_id])
    render json: {page: page_path}
  end

  def after_change_path(requirement_id)
    @requirement = Requirement.find(requirement_id)
    edit_requirement_path(requirement: @requirement.id, id: requirement_id)
  end

end