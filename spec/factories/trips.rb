FactoryBot.define do
  factory :trip do
    destination { 'Florianopolis' }
    starts_at { 2.weeks.from_now }
    ends_at { 5.weeks.from_now }
    is_confirmed { false }
  end
end
