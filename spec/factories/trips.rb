FactoryBot.define do
  factory :trip do
    destination { "Florianopolis" }
    starts_at { 2.week.from_now }
    ends_at { 5.week.from_now }
  end
end
