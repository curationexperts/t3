FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    display_name { Faker::Name.name }

    factory :super_admin do
      roles { [Role.find_by(name: 'Super Admin')] }
    end
  end

  factory :guest, class: 'User' do
    email { "guest_#{Faker::Internet.uuid}@example.com" }
    guest { true }
    to_create { |instance| instance.save(validate: false) }
  end

  # Sample authentication hash for google / omniauth
  # source: https://github.com/zquestz/omniauth-google-oauth2#auth-hash
  factory :google_auth_hash, class: 'OmniAuth::AuthHash' do
    sample = OmniAuth::AuthHash.new({
                                      'provider' => 'google_oauth2',
                                      'uid' => '100000000000000000000',
                                      'info' => {
                                        'name' => 'John Smith',
                                        'email' => 'john@example.com',
                                        'first_name' => 'John',
                                        'last_name' => 'Smith',
                                        'image' => 'https://lh4.googleusercontent.com/photo.jpg',
                                        'urls' => {
                                          'google' => 'https://plus.google.com/+JohnSmith'
                                        }
                                      },
                                      'credentials' => {
                                        'token' => 'TOKEN',
                                        'refresh_token' => 'REFRESH_TOKEN',
                                        'expires_at' => 1_496_120_719,
                                        'expires' => true
                                      },
                                      'extra' => {
                                        'id_token' => 'ID_TOKEN',
                                        'id_info' => {
                                          'azp' => 'APP_ID',
                                          'aud' => 'APP_ID',
                                          'sub' => '100000000000000000000',
                                          'email' => 'john@example.com',
                                          'email_verified' => true,
                                          'at_hash' => 'HK6E_P6Dh8Y93mRNtsDB1Q',
                                          'iss' => 'accounts.google.com',
                                          'iat' => 1_496_117_119,
                                          'exp' => 1_496_120_719
                                        },
                                        'raw_info' => {
                                          'sub' => '100000000000000000000',
                                          'name' => 'John Smith',
                                          'given_name' => 'John',
                                          'family_name' => 'Smith',
                                          'profile' => 'https://plus.google.com/+JohnSmith',
                                          'picture' => 'https://lh4.googleusercontent.com/photo.jpg?sz=50',
                                          'email' => 'john@example.com',
                                          'email_verified' => 'true',
                                          'locale' => 'en',
                                          'hd' => 'company.com'
                                        }
                                      }
                                    })

    # We want to cut & paste the sample exactly, but we've renamed our provider
    sample.provider = 'google'

    initialize_with { sample }
    skip_create
  end
end
