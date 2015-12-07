
FactoryGirl.define do
  factory :requirement do
    title          "some title"
    description    "some description"
    priority       5
    worth          10
    is_active      true
    project_id     1

    association(:project)
    Requirement.skip_callback(:create, :before)
  end
end