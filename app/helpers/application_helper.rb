module ApplicationHelper
  def edit_link(title, path)
    link_to title, path, class: "btn btn-primary frame-link"
  end

  def create_link(title, path)
     link_to title, path, class: "btn btn-success frame-link"
  end

  def delete_link(title, path)
    link_to title, path, class: "btn btn-danger delete-frame-link"
  end
end
