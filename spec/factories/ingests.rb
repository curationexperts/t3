FactoryBot.define do
  factory :ingest do
    user factory: %i[super_admin]
    status { :initialized }
    manifest { Rack::Test::UploadedFile.new('spec/fixtures/files/manifest.json', 'application/json') }
  end
end
