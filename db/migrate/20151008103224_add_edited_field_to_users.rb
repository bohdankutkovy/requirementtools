class AddEditedFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :info_edited, :boolean, default: false, :null => false
  end
end
