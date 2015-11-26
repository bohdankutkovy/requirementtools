FactoryGirl.define do
  factory :project do
    title         { Faker::Name.title }
    description   "Project description"

  end
end