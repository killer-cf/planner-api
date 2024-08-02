FactoryBot.define do
  factory :activity do
    title { 'MyString' }
    occurs_at { 1.day.from_now }
    trip { create :trip, starts_at: 1.day.from_now, ends_at: 7.days.from_now }
  end
end
