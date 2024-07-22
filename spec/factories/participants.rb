FactoryBot.define do
  factory :participant do
    sequence(:name) { |n| "user #{n}" }
    sequence(:email) { |n| "email.user#{n}@gmail.com" }
    is_confirmed { false }
    is_owner { false }
    trip { nil }
  end
end
