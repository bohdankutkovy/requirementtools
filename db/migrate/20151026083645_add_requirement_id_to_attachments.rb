class AddRequirementIdToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :requirement_id, :integer
  end
end
