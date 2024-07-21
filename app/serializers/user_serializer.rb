class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :trip_ids

  delegate :trip_ids, to: :object
end
