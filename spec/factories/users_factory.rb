# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name 'Test'
    last_name 'User'
    email 'example@example.com'
    password 'changeme'
    password_confirmation 'changeme'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
    factory :user_with_places do
      first_name 'WithPlaces'
      after(:create) do |u|
        u.places << FactoryGirl.create(:user_place1)
        u.places << FactoryGirl.create(:user_place2)
        u.save
      end
    end
    factory :user2 do
      first_name 'Test2'
      last_name 'User'
      email 'example2@example.com'
    end
    factory :admin do
    first_name 'Admin'
    last_name 'User'
      email 'admin@example.com'
      after(:create) do |u|
        u.add_role 'admin'
        u.save
      end
    end
  end
end
