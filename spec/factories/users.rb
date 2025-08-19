FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    role { 'user' }

    trait :admin do
      role { 'admin' }
      admin_level { 'super' }
    end

    trait :vip do
      vip_status { true }
      vip_expires_at { 1.year.from_now }
    end

    trait :moderator do
      role { 'moderator' }
      can_moderate { true }
    end

    trait :inactive do
      active { false }
      deactivated_at { Time.current }
    end
  end
end
