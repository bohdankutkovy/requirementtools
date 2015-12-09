# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
User.create(:email => "admin@example.com",
             :name => "JulesAbrams",
             :password => "adminpassword",
             :confirmed_at => DateTime.now,
             :is_super_admin => true,
             :info_edited => false)
#   Mayor.create(name: 'Emanuel', city: cities.first)
