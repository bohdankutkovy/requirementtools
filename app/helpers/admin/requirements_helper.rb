module Admin::RequirementsHelper
  def author_id_column(record, field)
    link_to User.find_by_id(record[:author_id]).name, profile_path(record[:author_id]), :target => "_blank"
  end

  def attachments_column(record, field)
    if Requirement.find(record.id).attachments.empty?
      "Add"
    else
      "Show(#{Requirement.find(record.id).attachments.count})"
    end


  end

  def children_column(record, field)
    if Requirement.find(record.id).children.empty?
      "Add"
    else
      "Show(#{Requirement.find(record.id).children.count})"
    end


  end
end

