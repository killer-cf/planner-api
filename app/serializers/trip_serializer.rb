class TripSerializer < ApplicationSerializer
  attributes :id, :destination, :starts_at, :ends_at, :is_confirmed
end
