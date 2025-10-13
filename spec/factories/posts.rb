# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph(sentence_count: 5) }
    association :author, factory: :user

    trait :published do
      published_at { Time.current }
      status { 'published' }
    end

    trait :draft do
      status { 'draft' }
      published_at { nil }
    end

    trait :featured do
      featured { true }
      featured_at { Time.current }
    end

    trait :with_comments do
      after(:create) do |post|
        create_list(:comment, rand(1..5), post: post)
      end
    end

    trait :with_tags do
      after(:create) do |post|
        post.tags = create_list(:tag, rand(2..4))
      end
    end
  end
end
