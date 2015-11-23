class AddActiveFieldToRequirements < ActiveRecord::Migration
  def change
    add_column :requirements, :is_active, :boolean, default: true
  end
end
