  class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.references :project, show: true
      t.integer    :parent_id, :default => 0, :null => false
      t.integer    :project_id, :null => false
      t.string     :title
      t.text       :description
      t.integer    :priority, :null => false
      t.integer    :worth, :null => false

      t.timestamps null: false
    end
  end
end
