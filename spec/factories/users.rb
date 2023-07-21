FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    factory :super_admin do
      roles { [Role.find_by(name: 'Super Admin')] }
    end
  end
end
