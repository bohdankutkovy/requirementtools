FactoryGirl.define do
  factory :attachment do
    file { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'fixtures', 'file',  'pdf.pdf')) }
    association(:requirement)
  end
end