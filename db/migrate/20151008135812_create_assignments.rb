class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|

      t.integer :project_id, :null => false
      t.integer :user_id, :null => false
      t.integer :acl_level, :default => 3, :null => false

      t.timestamps null: false
    end
  end
end
