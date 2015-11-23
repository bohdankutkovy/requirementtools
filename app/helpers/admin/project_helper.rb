module Admin::ProjectHelper
  def requirements_column(record, field)
    if Requirement.where(:project_id => record.id).empty?
      "Add"
    else
      "Show"
    end
  end

  def assignments_column(record, field)
    if Assignment.where(:project_id => record.id).empty?
      "Add"
    else
      "Show"
    end
  end
end
