FactoryBot.define do
  factory :custom_domain, class: 'CustomDomain' do
    host { Faker::Internet.domain_name(subdomain: true) }
  end
end
