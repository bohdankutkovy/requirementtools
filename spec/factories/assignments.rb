FactoryGirl.define do
  factory :assignment do
    project_id   0
    user_id      0
    acl_level    3
    created_at   Date.today
  end
end