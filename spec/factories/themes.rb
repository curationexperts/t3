FactoryBot.define do
  factory :theme do
    label { 'Theme Label' }
    site_name { 'My Site' }

    trait :with_logo do
      main_logo { Rack::Test::UploadedFile.new('spec/fixtures/files/sample_logo.png', 'image/png') }
    end
  end
end
