class Ability
  include CanCan::Ability

  def default_alias_actions
    {}
  end

  def initialize(user)
    alias_action  :create, :new, :show, :read, :show, :list, :show_search, 
                  :render_field, :update, :edit, :update_column, 
                  :edit_associated, :new_existing, :add_existing, 
                  :destroy, :delete, :destroy_existing, to: :crud

    alias_action  :update, :edit, to: :change

    return unless user

    if user.is_super_admin?
      can :manage, [ 
        Project,
        User,
        Assignment,
        Requirement,
        DashboardsController,
        Attachment
      ]

    else

      can :manage, DashboardsController
      can :read,   User
      can :show,   Requirement
      can :manage,   Attachment

      can :change, User do |u|
        u==user
      end

      project_ability(user)
      requirement_ability(user)
      assignment_ability(user)
    end

  end

  private

  def project_ability(user)
    can :show,    Project
    can(:show,    Project) { |project| project.available_for_read?(user)   }
    can(:change,  Project) { |project| project.available_for_update?(user) }
    can(:destroy, Project) { |project| project.available_for_delete?(user) }
  end

  def requirement_ability(user)
    can(:show,           Requirement) { |requirement| requirement.available_for_read?(user)   }
    can([:create, :new], Requirement) { |requirement| requirement.available_for_create?(user) }
    can(:change,         Requirement) { |requirement| requirement.available_for_update?(user) }
    can(:destroy,        Requirement) { |requirement| requirement.available_for_delete?(user) }
  end

  def assignment_ability(user)
    can(:destroy,        Assignment) { |assignment| assignment.available_for_delete?(user) }
    can([:create, :new], Assignment) { |assignment| assignment.available_for_create?(user) } 
    can(:show,           Assignment) { |assignment| assignment.available_for_read?(user)   }
    can(:change,         Assignment) { |assignment| assignment.available_for_update?(user) }
  end

end

