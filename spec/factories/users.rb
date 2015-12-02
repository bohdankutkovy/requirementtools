
FactoryGirl.define do
  factory :user do
    name                  {Faker::Name.name}
    email                 {Faker::Internet.email}
    password              "password"
    password_confirmation "password"
    info_edited           true
    is_super_admin        false
    is_active             true
    confirmed_at          Date.today
  end
end