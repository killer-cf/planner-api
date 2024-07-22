FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "user #{n}" }
    sequence(:email) { |n| "email.user#{n}@gmail.com" }
    external_id { SecureRandom.uuid }
  end
end
