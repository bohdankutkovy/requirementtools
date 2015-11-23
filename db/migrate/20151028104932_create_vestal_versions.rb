class CreateVestalVersions < ActiveRecord::Migration
  def self.up
  		create_table :versions do |t|
  			t.belongs_to :versioned, :polymorphic => true
  			t.belongs_to :requirement, :polymorphic => true
				t.string  :user_name
  			t.integer :project_id
  			t.integer :parent_id
  			t.string  :title
  			t.text    :description
  			t.integer :priority
  			t.integer :worth
  			t.text    :modifications
  			t.integer :number
  			t.integer :reverted_from
  			t.string  :tag
  			t.timestamps
  		end

  	end

  	def self.down
  		drop_table :versions
  	end

end
