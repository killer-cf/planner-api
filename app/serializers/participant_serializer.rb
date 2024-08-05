class ParticipantSerializer < ApplicationSerializer
  attributes :id, :name, :email, :is_confirmed, :is_owner
  belongs_to :user
end
