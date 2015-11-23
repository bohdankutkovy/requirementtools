module RequirementsHelper

  def requirement_to_bootstrap_tree_item(requirement)
    tree_nodes = requirement.children.map do |child|
      tree_item = requirement_to_bootstrap_tree_item(child)
      requirement.is_active ? tree_item : nil
    end
    if requirement.is_active
      node_link = requirement_to_bootstrap_tree_link(requirement)
      {text: node_link, nodes: tree_nodes.compact }
    end
  end

  def requirement_to_bootstrap_tree_link(requirement)
    link_to requirement.title, requirement_path(requirement.id), class: 'treerequirement frame-link', id: requirement.id
  end

  def breadcrumbs_for_requirement(req)
    breadcrumbs_arr = []
    cur_parent = req.parent_id
    while cur_parent > 0
      breadcrumbs_arr << [req.title, "/requirements/#{req.id}\""]

      if !Requirement.where(:id => req.parent_id).empty?
        req = Requirement.find(req.parent_id)
        cur_parent = req.parent_id
      end
    end
    breadcrumbs_arr << [req.title, "/requirements/#{req.id}\""]
    breadcrumbs_arr << [ Project.find(req.project_id).title, "/projects/#{Project.find(req.project_id).id}\""]
    breadcrumbs_arr.reverse!
  end

  def project_requirements_for_select(project_id)
    result = []
    requirement_ids = Requirement.is_active_by_project(project_id).where(parent_id: 0).map{|req| req.self_and_descendents }
    requirement_ids.map{|set| result += set.map{ |req| [depth(req).to_s +  req.title, req.id] }}
    result
  end

  def depth(req)
    parent_id = req.parent_id
    row = ""
    while parent_id != 0
      father = Requirement.find(parent_id)
      row += "=" * father.title.length if parent_id != 0
      parent_id = father.parent_id
    end
    row
  end

  def link_to_author(author_id)
    link_to( User.find(author_id).name, profile_path(author_id) , :target => '_blank')
  end

  def changed_attribute_of_version(version)
    version.modifications.keys
  end

  def changed_values_of_version(version, key)
    version.modifications[key.to_s]
  end


end

