class ParticipantSerializer < ApplicationSerializer
  attributes :id, :name, :email, :is_confirmed
  belongs_to :user
end
