FactoryBot.define do
  factory :participant do
    name { "MyString" }
    email { "MyString" }
    is_confirmed { false }
    is_owner { false }
    trip { nil }
  end
end
