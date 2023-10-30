FactoryBot.define do
  factory :ingest do
    user factory: %i[super_admin]
    status { :initialized }
  end
end
