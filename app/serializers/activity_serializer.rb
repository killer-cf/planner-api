class ActivitySerializer < ApplicationSerializer
  attributes :id, :title, :occurs_at
  has_one :trip
end
