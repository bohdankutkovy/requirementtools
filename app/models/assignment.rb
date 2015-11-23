class Assignment < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_presence_of :acl_level
  validates_presence_of :project_id

  validates_numericality_of :acl_level, greater_than_or_equal_to: 0, less_than: 4
  
  validates_uniqueness_of :user_id, scope: [:project_id], message: 'cannot be assigned to one project more than once'

  ACL_LEVELS = {
      0 => 'SuperAdmin',
      1 => 'ProjectAdmin',
      2 => 'ProjectUser',
      3 => 'ProjectViewer'
  }.freeze

  def name
    "#{user.name}" 
  end

  def authorized_for?(action)
    if current_user.is_super_admin?
      true
    end
  end

  def available_for_create?(user)
    user_has_ability = current_user.assignments.where(project_id: project_id).first.acl_level < 3
    user.is_super_admin? || user_has_ability
  end

  def available_for_read?(user)
    user_has_ability = current_user.assignments.where(project_id: project.id).first.acl_level <= 0
    user.is_super_admin? || user_has_ability
  end

  def available_for_update?(user)
    current_user_acl = current_user.assignments.where(project_id: project.id).first.acl_level

    case current_user_acl
      when 0
        user_has_ability = true
      when 1, 2
        assignment = User.find_by_id(user_id).assignments.find_by_id(id)
        user_has_ability = true if assignment && assignment.acl_level > current_user_acl
      when 3
        user_has_ability = false
    end
    user.is_super_admin? || user_has_ability
  end

  def available_for_delete?(user)
    user_has_ability = false
    current_user_acl = current_user.assignments.where(project_id: project.id).first.acl_level

    case current_user_acl
      when 0
        user_has_ability = true
      when 1, 2
        assignment = User.find_by_id(user_id).assignments.find_by_id(id)
        user_has_ability = true if assignment && assignment.acl_level > current_user_acl
      when 3
        user_has_ability = false
    end
    user.is_super_admin? || user_has_ability
  end

end
