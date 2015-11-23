class AddSuperadminUser < ActiveRecord::Migration
  def self.up
    superadmin = User.create!(:email => "admin@example.com",
                              :name => "JulesAbrams",
                              :password => "adminpassword",
                              :confirmed_at => DateTime.now,
                              :is_super_admin => true,
                              :info_edited => false)
  end

  def self.down
    if User.find_by_name( 'JulesAbrams' )
      superadmin = User.find_by_name( 'JulesAbrams' )
      superadmin.destroy
    end
  end
end
