class AddAuthorIdToRequirements < ActiveRecord::Migration
  def change
    add_column :requirements, :author_id, :integer
  end
end
