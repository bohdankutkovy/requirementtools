class AddSuperAdminFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_super_admin, :boolean, default: false, :null => false
  end
end

