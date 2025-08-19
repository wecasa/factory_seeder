FactoryBot.define do
  factory :comment do
    content { Faker::Lorem.paragraph(sentence_count: 2) }
    association :author, factory: :user
    association :post, factory: :post
    
    trait :approved do
      status { "approved" }
      approved_at { Time.current }
    end
    
    trait :pending do
      status { "pending" }
    end
    
    trait :spam do
      status { "spam" }
      spam_score { rand(0.8..1.0) }
    end
    
    trait :with_replies do
      after(:create) do |comment|
        create_list(:comment, rand(1..3), parent: comment, post: comment.post)
      end
    end
  end
end
