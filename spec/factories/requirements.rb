
FactoryGirl.define do
  factory :requirement do
    title          "some title"
    description    "some description"
    priority       5
    worth          10
    is_active      true
    project_id     1

    Requirement.skip_callback(:create, :before, :set_author)
  end
end