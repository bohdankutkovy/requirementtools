class Project < ActiveRecord::Base
  has_many :requirements, dependent: :destroy
  has_many :assignments,  dependent: :destroy
  has_many :users,        through:   :assignments

  validates_presence_of :title, :description
  validates_uniqueness_of :title

  def user_name
  end

  def authorized_for?(action)
    true if current_user.is_super_admin?
  end

  def available_for_read?(user)
    assignnment_exists = Assignment.count(conditions: {user_id: user.id, project_id: self.id}) > 0
    user.is_super_admin? || assignnment_exists
  end

  def available_for_update?(user)
    assignnment_exists = Assignment.where("user_id = #{user.id} AND project_id = #{self.id} AND acl_level <= 1").count > 0
    user.is_super_admin? || assignnment_exists
  end

  def available_for_delete?(user)
    assignnment_exists = Assignment.where("user_id = #{user.id} AND project_id = #{self.id} AND acl_level < 1").count > 0
    user.is_super_admin? || assignnment_exists
  end

  def unassigned_users
    User.is_active - assignments.map{ |assignment| assignment.user }
  end

end
